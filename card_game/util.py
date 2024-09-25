def print_color(message, color):
    color_start = "\033" + color
    color_end = "\033[0m"
    print(color_start + str(message) + color_end)


def warn(message):
    print_color(message, '[93m')


def print_file(name):
    file = open(name, 'r', encoding="utf-8")
    print(file.read(), end='')
    file.close()
