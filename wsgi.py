from traceback import format_exc
from flask import Flask, request, Response, jsonify
from main import *

app = Flask(__name__, static_url_path='/static')
app.config['JSON_SORT_KEYS'] = False
app.config['SESSION_COOKIE_SAMESITE'] = "Strict"


PLAIN_CONTENT_TYPE = "text/plain"
JSON_RESPONSE_HEADERS = {'Cache-Control': "no-cache, no-store"}
VALID_ACTIONS = ('version', 'init', 'plan', 'apply', 'providers')


def _main(module, workspace, form):

    try:
        action = form.get('action', 'plan')
        if action not in VALID_ACTIONS:
            raise f"Unsupported action '{action}'"
        _ = main(module, workspace, action)
        return _
    except Exception as e:
        raise e


@app.route("/<module>/")
def _module(module: str):

    try:
        _ = _main(module, workspace=None, form=request.form)
        return Response(format(_), status=200, content_type=PLAIN_CONTENT_TYPE)
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/<module>/<workspace>")
def _workspace(module: str, workspace: str = None):

    try:
        _ = _main(module, workspace=workspace, form=request.form)
        return Response(format(_), status=200, content_type=PLAIN_CONTENT_TYPE)
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


@app.route("/environments")
def _environments():

    try:
        environments = get_environment()
        if request.args.get('format') == 'hcl':
            _ = [f"{k} = {v}\n" if isinstance(v, int) else f"{k} = \"{v}\"\n" for k, v in environments.items()]
            return Response(_, content_type=PLAIN_CONTENT_TYPE)
        return jsonify(list(environments.keys())), JSON_RESPONSE_HEADERS
    except Exception as e:
        return Response(format_exc(), status=500, content_type=PLAIN_CONTENT_TYPE)


if __name__ == "__main__":

    app.run(debug=True)
