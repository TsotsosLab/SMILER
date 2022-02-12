import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="smiler_tools",
    version="1.3.0",
    author="Toni Kunic",
    author_email="tk@eecs.yorku.ca",
    description="Helper package for SMILER.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/tsotsoslab/SMILER",
    packages=setuptools.find_packages(),
    install_requires=[
        'numpy',
        'scipy==1.2.1',
        'pillow==5.1',
    ],
    classifiers=(
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: GNU Lesser General Public License v3 (LGPLv3)",
        "Operating System :: POSIX :: Linux",
    ),
)
