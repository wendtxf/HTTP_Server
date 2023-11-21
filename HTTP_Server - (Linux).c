#include <stdio.h>
#include <stdlib.h>

int main(){
    char tree;

    system("clear");
    printf("===========");
    printf(" HTTP Server");
    printf(" ===========\n\n");
    printf("Listar Árvore de Diretórios? (S/N): ");
    scanf("%s",&tree);
    printf("\n");

    if(tree == 's' || tree == 'S'){
        system("clear");
        printf("===========");
        printf(" HTTP Server");
        printf(" ===========\n\n");

        printf("Inicialização Concluída!\n\n");
        system("hostname; hostname -I | cut -f1 -d' '; echo Service: 8000; echo");
        printf("Listando...\n");

        system("tree /mnt/c/Users/'wendtxf'/Nextcloud/Ferramentas");
    }else if(tree == 'n' || tree == 'N'){
        system("clear");
        printf("===========");
        printf(" HTTP Server");
        printf(" ===========\n\n");

        printf("Inicialização Concluída!\n\n");
        system("hostname; hostname -I | cut -f1 -d' '; echo Service: 8000; echo");
    }else{
        system("clear");
        printf("===========");
        printf(" HTTP Server");
        printf(" ===========\n\n");

        printf("Inicialização Concluída!\n\n");
        system("hostname; hostname -I | cut -f1 -d' '; echo Service: 8000; echo");
    }

  //   ip -4 addr show wifi0 | grep -oP '(?<=inet/s)/d+(/./d+){3}'");

    system("python3 -m http.server -d /mnt/c/Users/'wendtxf'/Nextcloud/Ferramentas");
    system("clear");
}