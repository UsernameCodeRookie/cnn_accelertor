from im2col import *
from preprocess import *

B, H, W, C = 2, 4, 4, 3

K, M = 2, 4

stride = 1
padding = 0

I, J = 20, 20

if __name__ == "__main__":

    E = (H - K) // stride + 1
    F = (W - K) // stride + 1

    ifmaps = torch.randint(0, 20, (B, H, W, C))

    filters = torch.randint(0, 20, (M, K, K))

    n_ifmaps = get_im2col_ifmaps(ifmaps, K, stride).T

    n_filters = get_im2col_filters(filters, C).T

    # ofmaps = torch.nn.functional.conv2d(
    #     ifmaps.permute(0, 3, 1, 2),
    #     filters.unsqueeze(1).repeat(1, C, 1, 1),
    #     stride=stride,
    #     padding=padding,
    # )

    # print(ofmaps)

    print_matrix_in(n_ifmaps.tolist(), "data/_ifmaps.txt", I)

    print_matrix_in(n_filters.tolist(), "data/_filters.txt", J)

    print(n_ifmaps.shape, n_filters.shape)

    n_ofmaps = torch.mm(n_ifmaps.T, n_filters)

    print_matrix_out(n_ofmaps.tolist(), "data/_ofmaps.txt")
