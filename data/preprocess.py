import torch
from typing import List


def dec2hex(x: int) -> str:

    if x < 0 or x > 255:
        # data width = 16 bits
        raise ValueError("Invalid value")

    val = hex(x)[2:]

    if len(val) < 4:
        val = "0" * (4 - len(val)) + val

    return val


def list_transpose(matrix: List[List[int]]) -> List[List[int]]:
    return [list(row) for row in zip(*matrix)]


def list_bias(matrix: List[List[int]]) -> List[List[int]]:
    return [[0] * i + row + [0] * (len(matrix) - i - 1) for i, row in enumerate(matrix)]


def print_matrix_in(matrix: List[List[int]], file_path: str, target_len: int = 0):

    matrix = list_transpose(matrix)
    matrix = list_bias(matrix)
    matrix = list_transpose(matrix)

    with open(file_path, "w") as f:
        for row in matrix:

            if target_len != 0 and len(row) < target_len:
                row = row + [0] * (target_len - len(row))

            f.write("_".join(map(dec2hex, row)))
            f.write("\n")


def print_matrix_out(matrix: List[List[int]], file_path: str):
    with open(file_path, "w") as f:
        for row in matrix:
            f.write(" ".join(map(hex, row)))
            f.write("\n")


if __name__ == "__main__":

    k = 7
    m = 8
    n = 9

    l_matrix = torch.randint(1, 16, (m, k))

    r_matrix = torch.randint(1, 16, (m, n))

    print_matrix_in(l_matrix.tolist(), "data/_ifmaps.txt")

    print_matrix_in(r_matrix.tolist(), "data/_filters.txt")

    o_matrix = torch.mm(l_matrix.T, r_matrix)

    print_matrix_out(o_matrix.tolist(), "data/_ofmaps.txt")
