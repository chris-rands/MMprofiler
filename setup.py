from setuptools import setup

setup(
    name='mmprofiler',
    version='0.1',
    py_modules=['mmprofiler'],
    install_requires=[
        'Click',
    ],
    entry_points='''
        [console_scripts]
        mmprofiler=scripts.mmprofiler:cli
    ''',
)
