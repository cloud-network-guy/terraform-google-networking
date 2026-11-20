#!/usr/bin/env python3

from traceback import format_exc
from asyncio import run
from flask import Flask, request, Response, jsonify, render_template
from main import *
from classes import *

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False
app.config['SESSION_COOKIE_SAMESITE'] = "Strict"


PLAIN_CONTENT_TYPE = "text/plain"
JSON_RESPONSE_HEADERS = {'Cache-Control': "no-cache, no-store"}


@app.route("/environments")
def _environments():

    try:
        environments = get_environments()
        return jsonify(list(environments.keys())), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/environments/<environment>/modules")
def _modules(environment: str):

    try:
        modules = []
        _ = run(get_modules(environment))
        for module in _:
            m = module.__dict__
            m['workspaces'] = [workspace.__dict__ for workspace in module.workspaces if module.uses_workspaces]
            modules.append(m)
        return jsonify(modules), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/environments/<environment>/modules/<module>/workspaces")
def _workspaces(environment: str, module: str):
    try:
        workspaces = run(get_workspaces(environment, module))
        workspaces = sorted(workspaces, key=lambda x: x.state_file['last_update'], reverse=True)
        return jsonify(workspaces), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)

"""
@app.route("/modules/<module>/workspaces")
def _workspaces(module: str):

    try:
        settings = get_settings()
        _ = get_directories(settings)
        root_dir = _.get('root')
        m = TFModule(module, join(root_dir, module))
        workspaces = get_workspaces(m)
        workspaces = sorted(workspaces, key=lambda w: w.state_file['last_update'], reverse=True)
        return jsonify([w.__dict__ for w in workspaces]), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)
"""


@app.route("/")
def _root():

    data = []

    try:
        environments = get_environments()
        if environment := request.args.get('environment'):
            if module := request.args.get('module'):
                title = "Workspaces"
                fields = {
                    'name': "Workspace Name",
                    'state_file_url': "State File Url",
                    'last_modified': "Last Modified",
                }
                modules = run(get_modules(environment, module))
                m = modules[0]
                for w in m.workspaces:
                    state_file_url = "Unknown"
                    last_modified = "N/A"
                    if state_file := w.state_file:
                        state_file_url = state_file.get('url')
                        _ = state_file.get('last_update', 0)
                        last_modified = str(datetime.fromtimestamp(_))
                    data.append({
                        'name': w.name,
                        'state_file_url': state_file_url,
                        'last_modified': last_modified,
                    })
            else:
                title = "Modules"
                fields = {
                    'name': "Module Name",
                    'backend_type': "Backend Type",
                    'backend_location': "Backend Location",
                    'num_workspaces': "Number of Workspaces",
                    'last_modified': "Last Modified",
                }
                modules = run(get_modules(environment))
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
        else:
            title = "Environments"
            fields = {
                'name': "Environment Name",
                'num_modules': "Number of Modules",
            }
            for k, v in environments.items():
                modules = run(get_modules(k))
                data.append({
                    'name': k,
                    'num_modules': len(modules),
                })
        return render_template(
                template_name_or_list='table.jinja',
                title=title,
                fields=fields,
                data=data
        )

    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


if __name__ == "__main__":

    app.run(debug=True)
