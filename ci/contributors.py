#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path
from functools import partial
from collections import namedtuple, defaultdict

Committer = namedtuple('Committer', ['name', 'email'])

BLACKLIST = ['GitHub', 'bors[bot]']
OVERWRITES = {
        'James Munns': {'name': 'James Munns', 'email': 'james.munns@ferrous-systems.com'},
}


def committer_log():
    """
    Generator, returning the commiter for each commit in the git repository.
    """
    command = ['git', 'log', '--pretty=%cn;%ce']
    result = subprocess.run(command, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    if result.returncode != 0:
        raise Exception(f"Error while running git command, details {result.stdout}")
    for line in result.stdout.decode('utf-8').split('\n'):
        if ';' in line:
            name, email = line.split(';')
            yield Committer(name, email)


def unique_committers():
    """
    Generator, returning all unique tuples of (name, email) for all commiters of the repository.
    """
    committers = set(committer_log())
    for c in committers:
        yield c


def create_view_model(committers):
    view_model = defaultdict(dict)
    for c in committers:
        view_model[c.name]['name'] = c.name
        view_model[c.name]['email'] = c.email
    return view_model


def update_view_model(model, preferences):
    for user, data in preferences.items():
        model[user]['name'] = data['name']
        model[user]['email'] = data['email']
    return model


def render(view_model):
    output = [
        "# Contributors",
        "",
        "Here is a list of the contributors who have helped creating this book:",
        "",
    ]
    for name, data in view_model.items():
        output.append(f"* [{data['name']}](mailto:{data['email']})")
    return '\n'.join(output)


def main():
    current_dir = Path(os.path.dirname(__file__))
    book_src_dir = current_dir.joinpath('..', 'src')
    contributers_md = book_src_dir.joinpath('contributors.md')
    committers = [c for c in unique_committers() if c.name not in BLACKLIST]
    view_model = create_view_model(committers)
    view_model = update_view_model(view_model, OVERWRITES)
    output = render(view_model)
    with open(contributers_md, 'w') as f: f.write(output)
    sys.exit(0)


if __name__ == '__main__':
    main()

