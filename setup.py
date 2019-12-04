from setuptools import setup, find_packages  # type: ignore

VERSION = '0.1.0'

setup(
    name="mkdocs-topdf",
    version=VERSION,
    url='https://github.com/kuri65536/mkdocs-topdf',
    license='MPL2',
    description='a mkdocs theme for generate pdf or printing',
    author='shimoda',
    author_email='kuri65536@hotmail.com',
    packages=find_packages(),
    include_package_data=True,
    entry_points={
        'mkdocs.themes': [
            'topdf = topdf',
        ]
    },
    zip_safe=False
)
