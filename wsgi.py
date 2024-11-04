#!/usr/bin/env python3

from traceback import format_exc
from asyncio import run
from flask import Flask, request, Response, jsonify, render_template
from main import *
from classes import *

app = Flask(__name__, static_url_path='/static')
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


@app.route("/environments/<environment>")
def _environment(environment: str):

    try:
        modules = []
        for module in run(get_modules(environment)):
            m = module.__dict__
            m['workspaces'] = [workspace.__dict__ for workspace in module.workspaces if module.uses_workspaces]
            modules.append(m)
        return jsonify(modules), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/environments/<environment>/modules")
def _modules(environment: str):

    try:
        modules = []
        for module in get_modules(environment):
            m = module.__dict__
            m['workspaces'] = [workspace.__dict__ for workspace in module.workspaces if module.uses_workspaces]
            modules.append(m)
        return jsonify(modules), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/modules")
def __modules():

    try:
        modules = []
        for module in get_modules():
            m = module.__dict__
            m['workspaces'] = [workspace.__dict__ for workspace in module.workspaces]
            modules.append(m)
        return jsonify(modules), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


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


@app.route("/")
def _root():

    try:

        if module := request.args.get('module'):
            title = "Workspaces"
            settings = get_settings()
            _ = get_directories(settings)
            if google_adc_key := settings.get('google_adc_key'):
                google_adc_key = join(PWD, settings.get('google_adc_key'))
            root_dir = _.get('root')
            m = TFModule(module, join(root_dir, module), google_adc_key)
            _ = m.get_backend_workspaces()
            workspaces = [TFWorkSpace(w, m.name, m.backend_location) for w in m.workspaces]
            #_ = [w.examine_state_file(google_adc_key) for w in workspaces]
            #print(m.workspace_details)
            for w in workspaces:
                if w.name in m.workspace_details:
                    w.state_file_size = m.workspace_details[w.name]['size']
                    w.state_file_last_update = str(datetime.fromtimestamp(m.workspace_details[w.name]['updated']))
            workspaces = sorted(workspaces, key=lambda x: x.state_file_last_update, reverse=True)
            fields = {
                'name': "Workspace Name",
                'module': "Module Name",
                'input_file': "Input File",
                'state_file_location': "State File Location",
                'state_file_size': "State File Size",
                'state_file_last_update': "State File Last Changed",
            }
            data = [w.__dict__ for w in workspaces]
        else:
            title = "Modules"
            modules = get_modules()
            fields = {
                'name': "Workspace Name",
                'num_workspaces': "Number of Workspaces",
                'backend_location': "Backend Location",
            }
            data = []
            for m in modules:
                data.append({k: len(m.workspaces) if k == 'num_workspaces' else getattr(m, k) for k in fields.keys()})

        return render_template(
            template_name_or_list='index.html',
            title=title,
            fields=fields,
            data=data
        )
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


if __name__ == "__main__":

    app.run(debug=True)
