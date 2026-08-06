"""Web 'native' extract backend — user plugin (OTG).

Provides a local, keyless ``web_extract`` backend backed by trafilatura
(bundled in the OTG internal venv), with a BeautifulSoup + markdownify
fallback. Enabled via ``plugins.enabled: [web/native]`` and selected via
``web.extract_backend: native`` in config.yaml.

NOTE: uses a RELATIVE import on purpose. The plugin loader executes this
module as ``hermes_plugins.web__native`` with ``__path__`` set to this
directory, so ``from .provider import ...`` resolves here regardless of
the frozen ``plugins`` package inside the exe PYZ (the bundled
``plugins/`` tree is shipped as data next to the frozen code, and would
shadow a user ``data/plugins`` on sys.path). The bundled plugins use
absolute ``plugins.web.<name>.provider`` imports because their modules
live inside that tree; a user plugin does not.
"""

from __future__ import annotations

from .provider import LocalExtractProvider


def register(ctx) -> None:
    """Register the native extract provider with the plugin context."""
    ctx.register_web_search_provider(LocalExtractProvider())
