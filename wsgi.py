from traceback import format_exc
from flask import Flask, request, Response
from main import main

app = Flask(__name__)

CONTENT_TYPE = "text/plain"
VALID_ACTIONS = ['version', 'init', 'plan', 'apply', 'providers']


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
        return Response(format(_), status=200, content_type=CONTENT_TYPE)
    except Exception as e:
        return Response(format(e), status=500, content_type=CONTENT_TYPE)


@app.route("/<module>/<workspace>")
def _workspace(module: str, workspace: str = None):

    try:
        _ = _main(module, workspace=workspace, form=request.form)
        return Response(format(_), status=200, content_type=CONTENT_TYPE)
    except Exception as e:
        return Response(format(e), status=500, content_type=CONTENT_TYPE)


if __name__ == "__main__":

    app.run(debug=True)
