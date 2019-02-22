import io
from os.path import dirname, join
from setuptools import setup

def get_version(relpath):
  """Read version info from a file without importing it"""
  for line in io.open(join(dirname(__file__), relpath), encoding="cp437"):
    if "__version__" in line:
      if '"' in line:
        # __version__ = "0.9"
        return line.split('"')[1]
      elif "'" in line:
        return line.split("'")[1]


setup(
    name='mmprofiler',
    version=get_version("mmprofiler/__init__.py"),
    packages=['mmprofiler'],
    install_requires=[
        'Click',
    ],
    package_data={'': [
        "mmprofiler/*",
                   ]},
    include_package_data=True,
    entry_points={'console_scripts': ['mmprofiler = mmprofiler.mmprofiler:cli']
          },
)
