import getopt
import logging
import os
import sys

from ebs_volume_tasks import cleanup

logging.basicConfig(level=os.environ["LOG_LEVEL"] if "LOG_LEVEL" in os.environ else logging.WARN)


def print_usage():
    print("Usage: python main.py [--dry-run] [--help]")
    print(
        "Scans the current AWS account for available EC2 volumes and deletes them if they are not bound to a PersistentVolume in an EKS cluster.")
    print()
    print("\t--dry-run\t\tDisplays output listing volumes that would be deleted without actually deleting anything.")
    print("\t--help, -h\t\tDisplays this help output.")


try:
    arguments, values = getopt.getopt(
        sys.argv[1:],
        "h",
        ["help", "dry-run"]
    )

    dry_run = False
    for arg, val in arguments:
        if arg in ("-h", "--help"):
            print_usage()
            exit(0)
        elif arg == "--dry-run":
            if val is not None and val != "":
                print("Unexpected argument value passed after --dry-run\n")
                print_usage()
                exit(1)
            dry_run = True
        else:
            print("Unexpected argument: %s\n" % arg)
            print_usage()
            exit(1)
    if len(values) != 0:
        print("Unexpected arguments\n")
        print_usage()
        exit(1)

    cleanup(dry_run)
except getopt.error as err:
    # output error, and return with an error code
    print(str(err))
