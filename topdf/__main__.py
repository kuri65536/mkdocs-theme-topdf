import sys
import os
from typing import List


def main(args: List[str]) -> int:
    if len(args) < 2 or args[1] != "--header":
        print("invalid argument: " + ' '.join(args))
        print("%s [--header]" % args[0])
        print("  --header   show html to use wkhtmltopdf")
        return 0
    d = os.path.dirname(__file__)
    d = os.path.join(d, "header.html")
    d = os.path.realpath(d)
    print(d)
    return 0


if __name__ == "__main__":
    main(sys.argv)
