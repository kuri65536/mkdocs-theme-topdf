from setuptools import setup, find_packages  # type: ignore


def readme():
    # type: () -> str
    with open('README.md') as f:
        return f.read()


VERSION = '1.3.0'

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
    test_suite='tests',
    entry_points={
        'mkdocs.themes': [
            'topdf = topdf',
        ],
        'console_scripts': ["topdf=topdf:main",
                            "todocx=topdf.html_conv_docx:main_script"]
    },
    install_requires=[
                      "mkdocs",
                      "python-docx",
                      "bs4",
                      "requests",
                      "opsdroid-get-image-size",
                      "cell_row_span @ "
                      "git+https://github.com/Neepawa/cell_row_span",
                      ],
    long_description_content_type='text/markdown',
    long_description=long_description + "\n\n" + readme(),
    zip_safe=False
)
