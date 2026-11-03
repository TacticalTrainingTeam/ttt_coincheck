#!/usr/bin/env python3

import os
import re
import sys

# COIN DATABASE VALIDATOR
# -----------------------
# Checks that every coin class in coin_check's db.hpp is also listed in weapons[]
# in config.cpp (and vice versa) - without that, addItem fails in-game with
# "not found". Also checks that coins are numbered 1..N without gaps (which
# fnc_buildDatabase relies on) and that every UID is a unique Steam64 ID.

ADDON_DIR = os.path.join("addons", "coin_check")
DB_PATH = os.path.join(ADDON_DIR, "db.hpp")
CONFIG_PATH = os.path.join(ADDON_DIR, "config.cpp")


def resolve_path(path):
    # Allow running from root directory and tools directory
    if os.path.exists("addons"):
        return path
    return os.path.join("..", path)


def strip_comments(content):
    content = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)
    return re.sub(r"//[^\n]*", "", content)


def parse_db(db_path):
    with open(db_path, "r", encoding="utf-8") as file:
        content = strip_comments(file.read())

    entries = re.findall(
        r"class\s+GVAR\(coin_(\d+)\)\s*:\s*GVAR\(coin_base\)\s*\{(.*?)\};",
        content,
        re.DOTALL,
    )

    coins = []
    for number, body in entries:
        uid = re.search(r'uid\s*=\s*"([^"]*)"', body)
        coins.append((int(number), uid.group(1) if uid else None))

    return coins


def parse_config(config_path):
    with open(config_path, "r", encoding="utf-8") as file:
        content = strip_comments(file.read())

    match = re.search(r"weapons\[\]\s*=\s*\{(.*?)\};", content, re.DOTALL)
    if not match:
        return None

    return [int(n) for n in re.findall(r"QGVAR\(coin_(\d+)\)", match.group(1))]


def validate(coins, weapons):
    errors = []

    numbers = [number for number, _ in coins]
    expected = list(range(1, len(numbers) + 1))
    if sorted(numbers) != expected:
        errors.append("db.hpp coins are not numbered 1..{} without gaps or duplicates: {}".format(len(numbers), sorted(numbers)))

    seen_uids = {}
    for number, uid in coins:
        if uid is None:
            errors.append("coin_{} has no uid".format(number))
        elif not re.fullmatch(r"7656\d{13}", uid):
            errors.append("coin_{} has an invalid Steam64 uid: \"{}\"".format(number, uid))
        elif uid in seen_uids:
            errors.append("coin_{} reuses the uid of coin_{}: {}".format(number, seen_uids[uid], uid))
        else:
            seen_uids[uid] = number

    if weapons is None:
        errors.append("Could not find weapons[] in config.cpp")
        return errors

    if len(weapons) != len(set(weapons)):
        errors.append("weapons[] in config.cpp contains duplicates")

    for number in sorted(set(numbers) - set(weapons)):
        errors.append("coin_{} is in db.hpp but missing from weapons[] in config.cpp".format(number))
    for number in sorted(set(weapons) - set(numbers)):
        errors.append("coin_{} is in weapons[] in config.cpp but missing from db.hpp".format(number))

    return errors


def main():
    print("Validating Coin Database")
    print("------------------------")

    coins = parse_db(resolve_path(DB_PATH))
    weapons = parse_config(resolve_path(CONFIG_PATH))

    errors = validate(coins, weapons)

    for error in errors:
        print("  ERROR: {}".format(error))

    print("Checked {} coin(s)".format(len(coins)))

    if errors:
        print("Coin Database Validation FAILED")
        return 1

    print("Coin Database Validation PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
