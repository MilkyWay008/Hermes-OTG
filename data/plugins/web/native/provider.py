"""Native (trafilatura) web content extraction — user plugin (OTG).

Subclasses :class:`agent.web_search_provider.WebSearchProvider`. Extracts
page text locally with trafilatura (bundled in the OTG internal venv);
falls back to BeautifulSoup + markdownify when trafilatura cannot find a
main-content block or is not installed. No API key, no external service —
works for any URL the machine can reach.

Config keys this provider responds to::

    web:
      extract_backend: "native"

Capabilities:
  - supports_search()  -> False (extraction only)
  - supports_extract() -> True

Result shape matches the legacy ``web_extract_tool`` pipeline exactly
(list of dicts with ``url``/``title``/``content``/``raw_content``/
``metadata``, plus ``error`` on per-URL failure) — see the ABC docstring
in ``agent/web_search_provider.py``.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List

from agent.web_search_provider import WebSearchProvider

logger = logging.getLogger(__name__)

try:
    import trafilatura  # noqa: WPS433 — bundled in the OTG venv
    _TRAFILATURA_AVAILABLE = True
except Exception:  # pragma: no cover
    trafilatura = None
    _TRAFILATURA_AVAILABLE = False


def _extract_with_trafilatura(url: str, html: str) -> Dict[str, Any]:
    """Run trafilatura's extractors on an already-fetched HTML string.

    Raises RuntimeError when no main content can be found (caller then
    falls back to bs4 + markdownify).
    """
    content = trafilatura.extract(
        html,
        include_comments=False,
        include_tables=True,
        favor_precision=True,
    )
    if not content:
        raise RuntimeError(
            f"trafilatura.extract found no main content for {url}"
        )
    title = ""
    try:
        meta = trafilatura.extract_metadata(html)
        if meta is not None and getattr(meta, "title", None):
            title = meta.title
    except Exception:  # noqa: BLE001 — metadata is best-effort
        pass
    return {
        "url": url,
        "title": title,
        "content": content,
        "raw_content": content,
        "metadata": {"sourceURL": url, "title": title, "engine": "trafilatura"},
    }


def _extract_with_bs4_markdownify(url: str, html: str) -> Dict[str, Any]:
    """Fallback extractor: strip boilerplate with bs4, convert with markdownify."""
    from bs4 import BeautifulSoup
    from markdownify import markdownify as md

    soup = BeautifulSoup(html, "lxml")
    for tag in soup(
        ["script", "style", "noscript", "nav", "footer", "header", "aside", "form"]
    ):
        tag.decompose()
    title = ""
    if soup.title is not None and soup.title.string:
        title = soup.title.string.strip()
    main = soup.find("main") or soup.find("article") or soup.body or soup
    content = md(str(main), heading_style="ATX")
    content = "\n".join(
        line.rstrip() for line in content.splitlines() if line.strip()
    )
    return {
        "url": url,
        "title": title,
        "content": content,
        "raw_content": content,
        "metadata": {"sourceURL": url, "title": title, "engine": "bs4+markdownify"},
    }


def _fetch(url: str) -> str:
    """Fetch raw page HTML. Prefers trafilatura; falls back to urllib."""
    if _TRAFILATURA_AVAILABLE:
        html = trafilatura.fetch_url(url)
        if html:
            return html
    import urllib.request

    with urllib.request.urlopen(url, timeout=30) as resp:  # noqa: S310 — same trust model as fetch_url
        return resp.read().decode("utf-8", errors="replace")


class LocalExtractProvider(WebSearchProvider):
    """Local, keyless web content extraction via trafilatura."""

    @property
    def name(self) -> str:
        return "native"

    @property
    def display_name(self) -> str:
        return "Native (trafilatura)"

    def is_available(self) -> bool:
        """True when trafilatura (or the bs4/markdownify fallback) imports.

        No network calls — this runs at tool-registration time and on
        every ``hermes tools`` paint.
        """
        if _TRAFILATURA_AVAILABLE:
            return True
        try:
            import bs4  # noqa: F401
            import markdownify  # noqa: F401
            return True
        except Exception:  # noqa: BLE001
            return False

    def supports_search(self) -> bool:
        return False

    def supports_extract(self) -> bool:
        return True

    def extract(self, urls: List[str], **kwargs: Any) -> List[Dict[str, Any]]:
        """Extract content from one or more URLs locally.

        Returns a list of result dicts shaped for the ``web_extract_tool``
        pipeline. On per-URL failure the result carries an ``error`` field
        rather than raising (mirrors the bundled providers). ``kwargs``
        may carry forward-compat fields (``format``, ``include_raw``,
        ``max_chars``) — unknown keys are ignored.
        """
        results: List[Dict[str, Any]] = []
        for url in urls:
            try:
                html = _fetch(url)
                if not html:
                    raise RuntimeError(f"no content fetched for {url}")
                try:
                    if _TRAFILATURA_AVAILABLE:
                        results.append(_extract_with_trafilatura(url, html))
                        continue
                except Exception as exc:  # noqa: BLE001
                    logger.debug("trafilatura extract failed for %s: %s", url, exc)
                results.append(_extract_with_bs4_markdownify(url, html))
            except Exception as exc:  # noqa: BLE001 — surface as per-URL failure
                logger.warning("native extract error for %s: %s", url, exc)
                results.append(
                    {"url": url, "title": "", "content": "", "error": str(exc)}
                )
        return results

    def get_setup_schema(self) -> Dict[str, Any]:
        return {
            "name": "Native (trafilatura)",
            "badge": "local",
            "tag": "Local content extraction with trafilatura — no API key required.",
            "env_vars": [],
        }
