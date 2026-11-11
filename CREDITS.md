# Credits

- **The Vault Is the Agent: Why Autonomous AI Needs an LLM Wiki as Its Second Brain**, X Article by SMF Works (11 November 2026): https://x.com/MichaelGannotti/status/2120592530450292935. This is the source of the status/supersedes/review_after fields, the extra folders, the nightly research prompt, and the six lint rules.

- **Andrej Karpathy, LLM Wiki** (GitHub gist): https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f. The source of the three-layer pattern; quoted passages are marked in the README.

- **Hermes Agent llm-wiki skill** (Nous Research, MIT): https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki. `templates/SCHEMA.md`, `templates/index.md`, `templates/log.md`, and `prompts/ingest.md` are adapted from it. The skill's own frontmatter (`optional-skills/research/llm-wiki/SKILL.md` in [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)) declares `license: MIT`. The project license notice, copied from https://raw.githubusercontent.com/NousResearch/hermes-agent/main/LICENSE (fetched 11 November 2026), is:

```
MIT License

Copyright (c) 2025 Nous Research

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
