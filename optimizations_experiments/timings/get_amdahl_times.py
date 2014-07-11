DIR = "log_amdahl"
SIZES = ['1000', '3000', '5000', '10000']
MODES = ['constant', 'precise']
THREADS = ['1', '2', '4', '8', '16', '24']
output_file = "total_seq-par_times_amdahl.log"
output_sum_file = "total_sum_times_amdahl.log"

def parse_amdahl_files():
    f = open(output_file, "w")
    f2 = open(output_sum_file, "w")
    f.write("#Amdahl timings\n#constant first, precise last\n#sequential first, parallel last\n")
    f2.write("#Amdahl timings\n#constant first, precise last, sum of both parallel and sequential portions\n")
    for size in SIZES:
        temp_line = "{}\t".format(size)
        sum_line = "{}\t".format(size)
        for mode in MODES:
            for thread in THREADS:
                file = open("{}/chord_{}_threads{}_{}.log".format(DIR, size, thread, mode), "r")
                lines = [line for line in file.read().splitlines() if "Amdahl" in line]
                # tuples containing (sequential,parallel) time
                if lines:
                    lines = [(((line.split(";")[0]).split(":")[-1]).strip(),
                             ((line.split(";")[1]).split(":")[1]).strip()) for line in lines][0]
                    temp_line += "{}\t{}\t".format(lines[0], lines[1])
                    sum_line += "{}\t".format(float(lines[0]) + float(lines[1]))
                else:
                    temp_line += "?\t\t?\t\t"
                    sum_line += "?\t"
        f.write(temp_line +"\n")
        f2.write(sum_line +"\n")
    f.close()
    f2.close()
if __name__ == "__main__":
    parse_amdahl_files()
    exit(0)
