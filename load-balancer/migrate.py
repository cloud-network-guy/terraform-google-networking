#!/usr/bin/env python3

from subprocess import Popen, PIPE
from pathlib import Path

try:
    process = Popen("terraform state list", stdout=PIPE, stderr=PIPE, shell=True)
    stdout = process.stdout.read()
    stderr = process.stderr.read()
except Exception as e:
    raise RuntimeError(e)

output = ""
for line in stdout.decode("utf-8").splitlines():
    resource = None
    module = line.replace('module.', '').split('.')[0].split("[")[0]
    new_key = None
    #print("module:", module)
    """
    if 'google_compute_health_check.default' in line:
        new_key = None
        resource = "google_compute_health_check.default"
    if 'null_resource.healthchecks' in line:
        new_key = None
        resource = "null_resource.healthcheck"
    if 'google_compute_backend_service' in line:
        new_key = None
        resource = "google_compute_backend_service.default"
    if 'null_resource.backend_service' in line:
        new_key = None
        resource = "null_resource.backend_service"
    """
    if "google_compute_network_endpoint_group.default" in line:
        new_key = None
        resource = "google_compute_network_endpoint_group.default"
    if "null_resource.gnegs" in line:
        new_key = None
        resource = "null_resource.gnegs"
    if "null_resource.rnegs" in line:
        new_key = None
        resource = "null_resource.rnegs"
    if "null_resource.znegs" in line:
        new_key = None
        resource = "null_resource.znegs"
    if "google_compute_network_endpoint.default" in line:
        new_key = str("0")
        resource = "google_compute_network_endpoint.default"
    if "google_compute_global_network_endpoint.default" in line:
        new_key = str("0")
        resource = "google_compute_global_network_endpoint.default"
    if resource:
        _ = line.split("\"")[1]
        main_key = _.split("\"")[0]
        #print(line, main_key)
        if new_key:
            target = f"module.{module}[\"{main_key}\"].{resource}[\"{new_key}\"]"
        else:
            target = f"module.{module}[\"{main_key}\"].{resource}[0]"
        output += f"moved {{\n  from = {line}\n  to = {target}\n}}\n"

moved_file = Path("moved.tf")
moved_file.write_text(output)
