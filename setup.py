from setuptools import setup, find_packages

VERSION = '0.0.1'

setup(
    name="mkdocs-to-pdf",
    version=VERSION,
    url='https://github.com/kuri65536/mkdocs-to-pdf',
    license='MPL2',
    description='a mkdocs theme for generate pdf or printing',
    author='shimoda',
    author_email='kuri65536@hotmail.com',
    packages=find_packages(),
    include_package_data=True,
    entry_points={
        'mkdocs.themes': [
            'themename = to_pdf',
        ]
    },
    zip_safe=False
)
