#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
#define BUFSIZE 1024 * 1024
struct statistics {
	uint64_t md_r;
	uint64_t md_w;
	uint64_t d_r;
	uint64_t d_w;
	uint64_t del;
	uint64_t j_w;
};
struct statistics stat;
int _g_cnt = 0;

char** str_split(char* a_str, const char a_delim)
{
	char** result    = 0;
	size_t count     = 0;
	char* tmp        = a_str;
	char* last_comma = 0;
	char delim[2];
	delim[0] = a_delim;
	delim[1] = 0;

	/* Count how many elements will be extracted. */
	while (*tmp)
	{
		if (a_delim == *tmp)
		{
			count++;
			last_comma = tmp;
		}
		tmp++;
	}
	/* Add space for trailing token. */
	count += last_comma < (a_str + strlen(a_str) - 1);
	/* Add space for terminating null string so caller
	   knows where the list of returned strings ends. */
	count++;
	_g_cnt = count;
	result = malloc(sizeof(char*) * count);
	if (result)
	{
		size_t idx  = 0;
		char* token = strtok(a_str, delim);
		while (token)
		{
			assert(idx < count);
			*(result + idx++) = strdup(token);
			token = strtok(0, delim);
		}
		//assert(idx == count - 1);

		*(result + idx) = 0;
	}
	return result;
}
uint64_t str_to_uint64_t (char *str) {
	uint64_t ret = 0;
	int len = strlen(str);
	for (int i=0; i<len; i++) {
		ret += str[i] - '0';
		ret *= 10;
	}
	ret /= 10;
	return ret;
}
char is_read (char *str) {
	int len = strlen(str);
	for (int i=0; i<len; i++) {
		if (str[i] == 'R') {
			return 'R';
		} else if (str[i] == 'W') {
			return 'W';
		} else if (str[i] == 'N') {
			return 'N';
		} else if (str[i] == 'D') {
			return 'T';
		}
	}
}
char is_metadata (char *str) {
	int len = strlen(str);
	for (int i=0; i<len; i++) {
		if (str[i] == 'M') {
			return 'M';
		}
	}
	return 'D';
}
int main(int argc, char **argv){

	uint64_t journal_min=UINT64_MAX;
	uint64_t journal_max=0;
	if(!(argc==3 || argc==5)){
		printf("usage: %s [input_file] [outpu_file] (journal start) (journal end)\n", argv[0]);
		exit(1);
	}

	if(argc==5){
		journal_min=atoll(argv[3]);
		journal_max=atoll(argv[4]);
	}

	char buf[BUFSIZE], *ret;
	char** tokens;
	FILE *stream, *out_stream;
	uint64_t lba, cnt;
	char rw;
	char md;
	int line = 0;
	stat.md_r = 0;
	stat.md_w = 0;
	stat.d_r = 0;
	stat.d_w = 0;
	stat.del = 0;
	stat.j_w = 0;
	stream = fopen(argv[1], "rb");
	out_stream=fopen(argv[2], "wb");
	
	if(!(stream && out_stream)){
		printf("fopen error!\n");
		exit(1);
	}

	while ((ret = fgets(buf, BUFSIZE, stream)) != NULL) {
		line++;
		buf[strlen(buf)-1] = 0;
		tokens = str_split(buf, ' ');
		if (tokens){
			if (_g_cnt == 5) {
				lba = str_to_uint64_t(*(tokens + 2)) ;
				//cnt = str_to_uint64_t(*(tokens + 3)) / 4096;
				cnt = str_to_uint64_t(*(tokens + 3));
				if (cnt % 512) {
					cnt = cnt / 512;
				} else {
					cnt = cnt / 512 + 1;
				}
				//printf("[%s] [%zu] [%zu]\n", *(tokens + 1), lba, cnt);
				rw = is_read(*(tokens + 1));
				md = is_metadata(*(tokens + 1));
				if (rw == 'R' && md == 'M') {
					stat.md_r += cnt;
				} else if (rw == 'R' && md == 'D') {
					stat.d_r += cnt;
				} else if (rw == 'W' && md == 'M') {
					stat.md_w += cnt;
				} else if (rw == 'W' && md == 'D') {
					stat.d_w += cnt;
				} else if (rw == 'T') {
					stat.del += cnt;
				}
				if (rw == 'W') {
					if (lba >= journal_min && lba <= journal_max) { 
						stat.j_w += cnt;
						if (md == 'D') 
							stat.d_w -= cnt;
						if (md == 'M') 
							stat.md_w -= cnt;

					}
				}
			}
			int i;
			for (i = 0; *(tokens + i); i++){
					free(*(tokens + i));
			}
			free(tokens);
		}
	}

	fprintf(out_stream,	"METADATA READ %zu\n", stat.md_r/8);
	fprintf(out_stream,	"METADATA WRITE %zu\n", stat.md_w/8);
	fprintf(out_stream,	"DATA READ %zu\n", stat.d_r/8);
	fprintf(out_stream,	"DATA WRITE %zu\n", stat.d_w/8);
	fprintf(out_stream,	"Delete %zu\n", stat.del/8);
	fprintf(out_stream,	"JW %zu\n", stat.j_w/8);
	fprintf(out_stream,	"%zu %zu %zu %zu %zu %zu\n", stat.md_r/8, stat.md_w/8, stat.d_r/8, stat.d_w/8, stat.j_w/8, stat.del/8);
	return 0;
}
