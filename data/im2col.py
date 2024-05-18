import torch


def get_pad_ifmaps(ifmaps: torch.Tensor, padding: int):
    pad_ifmaps = torch.nn.functional.pad(
        ifmaps, (0, 0, 0, 0, padding, padding, padding, padding), "constant", 0
    )
    return pad_ifmaps


def get_im2col_filters(filters: torch.Tensor, C: int):
    M, K, _ = filters.shape
    im2col_filters = filters.reshape(M, K * K)

    C_im2col_filters = torch.zeros((M, C * K * K), dtype=im2col_filters.dtype)

    for m in range(M):
        for kk in range(K * K):
            C_im2col_filters[m, kk * C : (kk + 1) * C] = im2col_filters[m, kk]

    return C_im2col_filters


def get_im2col_ifmaps(ifmaps: torch.Tensor, K: int, stride: int):
    B, H, W, C = ifmaps.shape
    E = (H - K) // stride + 1
    F = (W - K) // stride + 1
    im2col_ifmaps = torch.zeros((B * E * F, C * K * K), dtype=ifmaps.dtype)

    for y in range(E):
        y_min = y * stride
        y_max = y_min + K
        y_start = y * F

        if y_max > H:
            continue

        for x in range(F):
            x_min = x * stride
            x_max = x_min + K

            if x_max > W:
                continue

            imm_map = ifmaps[:, y_min:y_max, x_min:x_max, :].reshape(B, K * K * C)

            im2col_ifmaps[y_start + x :: E * F, :] = imm_map

    return im2col_ifmaps


if __name__ == "__main__":

    B, H, W, C = 2, 4, 4, 3

    K, M = 2, 4

    stride = 1
    padding = 0

    E = (H - K) // stride + 1
    F = (W - K) // stride + 1

    ifmaps = torch.randint(0, 20, (B, H, W, C)).float()

    filters = torch.randint(0, 20, (M, K, K)).float()

    n_ifmaps = get_im2col_ifmaps(ifmaps, K, stride)

    n_filters = get_im2col_filters(filters, C)

    n_ofmaps = torch.mm(n_ifmaps, n_filters.T)

    n_ofmaps = n_ofmaps.reshape(B, E * F, M)

    ofmaps = torch.nn.functional.conv2d(
        ifmaps.permute(0, 3, 1, 2),
        filters.unsqueeze(1).repeat(1, C, 1, 1),
        stride=stride,
        padding=padding,
    )

    print(ofmaps)
    print(n_ofmaps)
