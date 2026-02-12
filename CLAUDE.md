## n8n Workflow Management
- Use `bash n8n-api.sh` to manage n8n workflows via the REST API
- Workflow JSON can be downloaded with `get`, modified, and pushed with `update`
- Always save workflow changes to project root for version control
- API credentials are in `.env.local` (never commit this file)

## Project: LinkedIn Post Agent
- RAG-powered chatbot that writes LinkedIn posts in the user's style
- n8n workflow with 2 flows: Document Upload + Chat Agent
- Vector store: Supabase pgvector
- Embeddings: OpenAI text-embedding-3-small (1536 dim)
- Chat model: Claude Sonnet via Anthropic API
- Landing page: linkedin-post-agent.html
