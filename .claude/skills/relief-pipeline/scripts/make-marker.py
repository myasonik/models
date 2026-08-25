#!/usr/bin/env python3
"""Generate a project's Relief Marker page.

Usage: make-marker.py <project-build-script.py> <out.html>

Imports the project script (which must expose CONFIG), then renders the
marker page from the template next to this script. Publish the result
as an artifact with capabilities {"artifact": {}} so Save works.
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from relief_lib import make_marker

proj, out = sys.argv[1], sys.argv[2]
spec = importlib.util.spec_from_file_location('project', proj)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
make_marker(mod.CONFIG, os.path.join(HERE, '..', 'templates', 'marker.html'), out)
