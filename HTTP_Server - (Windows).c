#include <stdio.h>
#include <stdlib.h>

int main(){
    char tree;

    system("chcp 1252");
    system("color D");
    system("cls");
    printf("===========");
    printf(" HTTP Server");
    printf(" ===========\n\n");
    printf("Listar ?rvore de Diret?rios? (S/N): ");
    scanf("%s",&tree);
    printf("\n");

    if(tree == 's' || tree == 'S'){
        system("cls");
        printf("===========");
        printf(" HTTP Server");
        printf(" ===========\n\n");

        printf("Inicialização Concluída!\n\n");
        system("   hostname");
        system("ipconfig | findstr /i IPv4");
        system("echo    Serviço Porta. . . . . . . .  . . . . . . . : 8000");
        printf("\n");
        printf("Listando...\n");
        system("tree C:/Users/wendtxf/Nextcloud/Ferramentas");
    }else if(tree == 'n' || tree == 'N'){
        system("cls");
        printf("===========");
        printf(" HTTP Server");
        printf(" ===========\n\n");

        printf("Inicialização Concluída!\n\n");
        system("   hostname");
        system("ipconfig | findstr /i IPv4");
        system("echo    Serviço Porta. . . . . . . .  . . . . . . . : 8000");
    }else{
        system("cls");
        printf("===========");
        printf(" HTTP Server");
        printf(" ===========\n\n");

        printf("Inicialização Concluída!\n\n");
        system("   hostname");
        system("ipconfig | findstr /i IPv4");
        system("echo    Serviço Porta. . . . . . . .  . . . . . . . : 8000");
    }

  //   ip -4 addr show wifi0 | grep -oP '(?<=inet/s)/d+(/./d+){3}'");

    printf("\n");
    system("python3 -m http.server -d \"G:/Meu Drive/Ferramentas\"");
    system("cls");

    return 0;
}
