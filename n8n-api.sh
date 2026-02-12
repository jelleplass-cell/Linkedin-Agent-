#!/bin/bash
# n8n REST API helper script for Claude Code
# Usage: bash n8n-api.sh <command> [args]

set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env.local" ]; then
  export $(grep -v '^#' "$SCRIPT_DIR/.env.local" | xargs)
fi

if [ -z "$N8N_API_URL" ] || [ -z "$N8N_API_KEY" ]; then
  echo "Error: N8N_API_URL and N8N_API_KEY must be set in .env.local"
  exit 1
fi

COMMAND=${1:-help}
shift 2>/dev/null || true

case "$COMMAND" in

  list)
    curl -s -X GET "$N8N_API_URL/workflows" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" | python3 -m json.tool
    ;;

  get)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh get <workflow-id>"; exit 1; fi
    curl -s -X GET "$N8N_API_URL/workflows/$1" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" | python3 -m json.tool
    ;;

  create)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh create <file.json>"; exit 1; fi
    if [ ! -f "$1" ]; then echo "Error: File $1 not found"; exit 1; fi
    curl -s -X POST "$N8N_API_URL/workflows" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d @"$1" | python3 -m json.tool
    ;;

  update)
    if [ -z "$1" ] || [ -z "$2" ]; then echo "Usage: bash n8n-api.sh update <workflow-id> <file.json>"; exit 1; fi
    if [ ! -f "$2" ]; then echo "Error: File $2 not found"; exit 1; fi
    curl -s -X PUT "$N8N_API_URL/workflows/$1" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d @"$2" | python3 -m json.tool
    ;;

  activate)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh activate <workflow-id>"; exit 1; fi
    curl -s -X PATCH "$N8N_API_URL/workflows/$1" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{"active": true}' | python3 -m json.tool
    ;;

  deactivate)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh deactivate <workflow-id>"; exit 1; fi
    curl -s -X PATCH "$N8N_API_URL/workflows/$1" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d '{"active": false}' | python3 -m json.tool
    ;;

  execute)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh execute <workflow-id>"; exit 1; fi
    curl -s -X POST "$N8N_API_URL/executions" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"workflowId\": \"$1\"}" | python3 -m json.tool
    ;;

  executions)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh executions <workflow-id>"; exit 1; fi
    curl -s -X GET "$N8N_API_URL/executions?workflowId=$1&limit=10" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" | python3 -m json.tool
    ;;

  delete)
    if [ -z "$1" ]; then echo "Usage: bash n8n-api.sh delete <workflow-id>"; exit 1; fi
    curl -s -X DELETE "$N8N_API_URL/workflows/$1" \
      -H "X-N8N-API-KEY: $N8N_API_KEY" | python3 -m json.tool
    ;;

  help|*)
    echo "n8n REST API Helper"
    echo ""
    echo "Usage: bash n8n-api.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  list                      List all workflows"
    echo "  get <id>                  Get workflow JSON by ID"
    echo "  create <file.json>        Create workflow from JSON file"
    echo "  update <id> <file.json>   Update workflow from JSON file"
    echo "  activate <id>             Activate a workflow"
    echo "  deactivate <id>           Deactivate a workflow"
    echo "  execute <id>              Execute a workflow"
    echo "  executions <id>           Get execution history"
    echo "  delete <id>               Delete a workflow"
    ;;

esac
