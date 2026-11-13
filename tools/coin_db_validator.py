#!/usr/bin/env python3

import os
import re
import sys

# COIN DATABASE VALIDATOR
# -----------------------
# Checks that every coin class in coin_check's db.hpp is also listed in weapons[]
# in config.cpp (and vice versa) - without that, addItem fails in-game with
# "not found". Also checks that the coin crate (crate.hpp) holds exactly one
# of every coin, that coins are numbered 1..N without gaps (which
# fnc_buildDatabase relies on) and that every UID is a unique Steam64 ID.

ADDON_DIR = os.path.join("addons", "coin_check")
DB_PATH = os.path.join(ADDON_DIR, "db.hpp")
CONFIG_PATH = os.path.join(ADDON_DIR, "config.cpp")
CRATE_PATH = os.path.join(ADDON_DIR, "crate.hpp")


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


def parse_crate(crate_path):
    with open(crate_path, "r", encoding="utf-8") as file:
        content = strip_comments(file.read())

    entry = r"class\s+(\w+)\s*\{\s*name\s*=\s*QGVAR\(coin_(\d+)\)\s*;\s*count\s*=\s*(\d+)\s*;\s*\};"
    entries = re.findall(entry, content)
    unparsed = re.sub(entry, "", content).strip()

    return [(name, int(number), int(count)) for name, number, count in entries], unparsed


def validate_crate(numbers, crate_entries, unparsed):
    errors = []

    if unparsed:
        errors.append("crate.hpp contains entries that are not of the form 'class _xx_coin_N { name = QGVAR(coin_N); count = 1; };'")

    crate_numbers = []
    for name, number, count in crate_entries:
        if name != "_xx_coin_{}".format(number):
            errors.append("crate.hpp entry {} holds coin_{}, expected class name _xx_coin_{}".format(name, number, number))
        if count != 1:
            errors.append("crate.hpp holds {} of coin_{}, expected 1".format(count, number))
        crate_numbers.append(number)

    if len(crate_numbers) != len(set(crate_numbers)):
        errors.append("crate.hpp contains duplicate coins")

    for number in sorted(set(numbers) - set(crate_numbers)):
        errors.append("coin_{} is in db.hpp but missing from crate.hpp".format(number))
    for number in sorted(set(crate_numbers) - set(numbers)):
        errors.append("coin_{} is in crate.hpp but missing from db.hpp".format(number))

    return errors


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

    crate_entries, crate_unparsed = parse_crate(resolve_path(CRATE_PATH))

    errors = validate(coins, weapons)
    errors += validate_crate([number for number, _ in coins], crate_entries, crate_unparsed)

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
