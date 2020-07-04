from setuptools import setup, find_packages  # type: ignore


def readme():
    # type: () -> str
    with open('README.md') as f:
        return f.read()


VERSION = '1.1.2'

long_description = (
    "This is a mkdocs theme, "
    "this supports some CSS-styles to publish your documents "
    "with PDF or printing."
    "Please see the 'Demo' section"
)

setup(
    name="mkdocs-theme-topdf",
    version=VERSION,
    url='https://github.com/kuri65536/mkdocs-theme-topdf',
    license='MPL2',
    description='a mkdocs theme for generate pdf or printing',
    author='Shimoda',
    author_email='kuri65536@hotmail.com',
    packages=find_packages(),
    include_package_data=True,
    entry_points={
        'mkdocs.themes': [
            'topdf = topdf',
        ]
    },
    require=["mkdocs",
             "python-docx",
             "bs4",
             "requests",
             "opsdroid-get-image-size",
             ],
    long_description_content_type='text/markdown',
    long_description=long_description + "\n\n" + readme(),
    zip_safe=False
)
