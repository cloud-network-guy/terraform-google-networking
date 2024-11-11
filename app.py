#!/usr/bin/env python3

from traceback import format_exc
from datetime import datetime
from quart import Quart, request, Response, jsonify, render_template
from main import get_environments, get_fields, get_modules, get_workspaces
#from classes import TFWorkSpace

app = Quart(__name__, static_url_path='/static')
app.config['JSON_SORT_KEYS'] = False
app.config['SESSION_COOKIE_SAMESITE'] = "Strict"


PLAIN_CONTENT_TYPE = "text/plain"
JSON_RESPONSE_HEADERS = {'Cache-Control': "no-cache, no-store"}
FIELDS = get_fields()
ENVIRONMENTS = get_environments()
TABLE_TEMPLATE = "table.jinja"


@app.route("/environments")
async def _environments():

    try:
        return jsonify(list(ENVIRONMENTS.keys())), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/environments/<environment>/modules")
async def _modules(environment: str):

    try:
        modules = []
        _ = await get_modules(environment)
        for module in _:
            m = module.__dict__
            m['workspaces'] = [workspace.__dict__ for workspace in module.workspaces if module.uses_workspaces]
            modules.append(m)
        return jsonify(modules), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/environments/<environment>/modules/<module>/workspaces")
async def _workspaces(environment: str, module: str):
    try:
        workspaces = await get_workspaces(environment, module)
        workspaces = sorted(workspaces, key=lambda x: x.state_file['last_update'], reverse=True)
        return jsonify(workspaces), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/")
async def _root():

    data = []

    try:

        if not (environment := request.args.get('environment')):
            title = "Environments"
            fields = FIELDS.get(title)
            for k, v in ENVIRONMENTS.items():
                modules = await get_modules(k)
                data.append({
                    'name': k,
                    'num_modules': len(modules),
                })
        else:
            if module := request.args.get('module'):
                title = "Workspaces"
                fields = FIELDS.get(title)
                modules = await get_modules(environment, module)
                m = modules[0]
                for w in m.workspaces:
                    state_file_url = "Unknown"
                    state_file_size = None
                    last_modified = "N/A"
                    if state_file := w.state_file:
                        state_file_url = state_file.get('url')
                        state_file_size = state_file.get('size', 0)
                        _ = state_file.get('last_update', 0)
                        last_modified = str(datetime.fromtimestamp(_))
                    data.append({
                        'name': w.name,
                        'input_file_url': w.input_file.get('path'),
                        'input_file_size': w.input_file.get('size'),
                        'state_file_url': state_file_url,
                        'state_file_size': state_file_size,
                        'last_modified': last_modified,
                    })
            else:
                title = "Modules"
                fields = FIELDS.get(title)
                modules = await get_modules(environment)
                for m in modules:
                    workspaces = m.workspaces
                    last_modified = "N/A"
                    if len(workspaces) > 0:
                        most_recent = workspaces[0]
                        if most_recent.state_file:
                            _ = most_recent.state_file.get('last_update', 0)
                            last_modified = str(datetime.fromtimestamp(_))
                    data.append({
                        'name': m.name,
                        'backend_type': m.backend.get('type', "Unknown"),
                        'backend_location': m.backend.get('location', "Unknown"),
                        'num_workspaces': len(m.workspaces),
                        'last_modified': last_modified,
                    })
        return await render_template(
                template_name_or_list=TABLE_TEMPLATE,
                title=title,
                fields=fields,
                data=data
        )
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


if __name__ == "__main__":

    app.run(debug=True, use_reloader=True)
