#!/usr/bin/env python

import sys


if len(sys.argv) <= 2:
    print("Usage: python {} mops_total.csv mops_ref.csv".format(sys.argv[0]))
    sys.exit(1)


def parseCSV(csv_file):
    new_test_results = {}

    for line in open(csv_file):
        tmp_list = line.rstrip().split(',')
        new_test_results[tmp_list[0]] = float(tmp_list[1])

    return new_test_results


new_results = parseCSV(sys.argv[1])
ref_results = parseCSV(sys.argv[2])
score = 0.0

for test_name in ref_results.keys():
    if test_name in new_results:
        score += new_results[test_name] / ref_results[test_name]

print(score / len(ref_results))
