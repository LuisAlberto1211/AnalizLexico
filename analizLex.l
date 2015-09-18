%{
  /*
    Garcia Aguilar Ricardo Daniel
    Ortega Vazquez Luis Alberto
    Compiladores
    Profesora: Laura Sandoval Montaño
    Descripcion:
      Identificar los diferentes componentes del lenguaje definido en clase
  */

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  //Longitud maxima de cada simbolo perteneciente a una tabla de operadores
  #define LONG_MAX_SYM 12
  #define LONG_MAX_PALRES 12
  #define LONG_MAX_STR 10

  //Total de simbolos en cada tabla de operador
  #define SIMB_REL_NUM 6
  #define SIMB_ASIG_NUM 1
  #define SIMB_ARIT_NUM 4
  #define SIMB_ESP_NUM 6
  #define SIMB_PALRES_NUM 14

  //Simbolos de palabras reservadas
  #define SIMB_PALRES {"_corto", "_desde", "_entero", "_finmientras", "_finsi", "_hasta", "_haz", "_incremento", "_largo", "_mientras", "_real", "_si", "_simbolo", "_sino"}
  //Simbolos de cada tabla de operadores
  #define SIMB_REL { ">", ">=", "<", "<=", "=", "><" }
  #define SIMB_ASIG { ":=" }
  #define SIMB_ARIT { "+", "-", "*", "/"}
  //Simbolos especiales
  #define SIMB_ESP {  ",", ".", "(", ")", "[", "]" }

  //Funcion encargada de encontrar una palabra (symb) en un arreglo (arr) de tamanio dado (tam)
  int buscaElemento(const char **arr, char *symb, char tam);

  //Estructura que almacena los diferentes operadores un arreglos distintos
  typedef struct{
    const char *palRes[SIMB_PALRES_NUM];
    const char *opRel[SIMB_REL_NUM];
    const char *opAsig[SIMB_ASIG_NUM];
    const char *opArit[SIMB_ARIT_NUM];
    const char *simbEsp[SIMB_ESP_NUM];
  }Operadores;

  //Estructura de lista ligada TOKENS
  struct nodoLista{
    char clase;
    char posicion;
    struct nodoLista *ptrSig;
  };

  typedef struct nodoLista NodoLista;
  typedef NodoLista *ptrNodoLista;

  //Estructura de lista ligada TOKENS
  struct nodoListaExpandible{
    char elemento[20];
    char clase;
    struct nodoListaExpandible *ptrSig;
  };

  typedef struct nodoListaExpandible NodoListaExpandible;
  typedef NodoListaExpandible *ptrNodoListaExpandible;

  //Funciones para el manejo de la lista ligada TOKENS
  void insertarToken( ptrNodoLista *ptrS, char clase, char posicion);
  void imprimeListaToken( ptrNodoLista ptrActual );

  //Funciones para el manejo de la lista ligada EXPANDIBLE
  void insertar( ptrNodoListaExpandible *ptrS, char *elemento, char clase);
  void imprimeLista( ptrNodoListaExpandible ptrActual );

  //Funciones que pasan los elementos de la lista a archivos
  void lista2ArchivoToken(ptrNodoLista ptrInicial, FILE *fp);
  void lista2Archivo(ptrNodoListaExpandible ptrInicial, char *titulo, FILE *fp);

  int i, j;
  Operadores op = { SIMB_PALRES, SIMB_REL, SIMB_ASIG, SIMB_ARIT, SIMB_ESP};  //Se inicializa las tablas de operadores

  //Archivo de salida
  FILE *archSalida;

  char c[16];

  //Estructuras donde se almacenaran las cadenas una vez identificadas
  ptrNodoLista ptrInicialTokens = NULL;
  ptrNodoListaExpandible ptrInicialIden = NULL;
  ptrNodoListaExpandible ptrInicialCad = NULL;
  ptrNodoListaExpandible ptrInicialConstEnt = NULL;
  ptrNodoListaExpandible ptrInicialConstReal = NULL;
  ptrNodoListaExpandible ptrInicialError = NULL;

%}
palRes     _corto|_desde|_entero|_finmientras|_finsi|_hasta|_haz|_incremento|_largo|_mientras|_real|_si|_simbolo|_sino
ident      [a-zA-Z]{1,16}
opAsig     :=
opRel      >=?|<=?|><|=
opArit     [\+\-*\/]
simbEsp    [\.,\(\)\[\]]
consCad    \".*\"
signo      [\+\-]
consEnt    {signo}?[0-9]+
sufijo     E{consEnt}
consReal   ({consEnt}?\.[0-9]+{sufijo}?)|({consEnt}\.{sufijo}?)
comentario ¡.*!
espacio    [ \n\t]+
error      [_:#$%&;{}?¿\\]+
%%
{palRes}      j = buscaElemento(op.palRes, yytext, SIMB_PALRES_NUM); insertarToken(&ptrInicialTokens, 0, j);
{ident}       insertar(&ptrInicialIden, yytext, 1);
{opAsig}      j = buscaElemento(op.opAsig, yytext, SIMB_ASIG_NUM); insertarToken(&ptrInicialTokens, 2, j);
{opRel}       j = buscaElemento(op.opRel, yytext, SIMB_REL_NUM); insertarToken(&ptrInicialTokens, 3, j);
{opArit}      j = buscaElemento(op.opArit, yytext, SIMB_ARIT_NUM); insertarToken(&ptrInicialTokens, 4, j);
{simbEsp}     j = buscaElemento(op.simbEsp, yytext, SIMB_ESP_NUM); insertarToken(&ptrInicialTokens, 5, j);
{consCad}     insertar(&ptrInicialCad,yytext, 6);
{consEnt}     insertar(&ptrInicialConstEnt,yytext, 7);
{sufijo}
{consReal}    insertar(&ptrInicialConstReal,yytext, 8);
{comentario}
{error}       insertar(&ptrInicialError,yytext, 9);
{espacio}
%%
int main(int argc, char *argv[]){
  archSalida = fopen("Salida.txt", "w");

  yyin = fopen(argv[1], "r");
  yylex();
  fclose(yyin);

  lista2ArchivoToken(ptrInicialTokens, archSalida);
  lista2Archivo(ptrInicialIden, "\nIdentificadores", archSalida);
  lista2Archivo(ptrInicialCad, "Cadenas", archSalida);
  lista2Archivo(ptrInicialConstEnt, "Constantes enteras", archSalida);
  lista2Archivo(ptrInicialConstReal, "Constantes reales", archSalida);
  lista2Archivo(ptrInicialError, "Errores", archSalida);

  fclose(archSalida);

  return 0;
}

//Buscar un elemento en una tabla estatica
int buscaElemento(const char **arr, char *symb, char tam){
  char i;
  for (i = 0; i < tam; i++){
    if(strncmp(arr[i], symb, LONG_MAX_SYM) == 0)
      return i;
  }
  return -1;
}

//Regresa el simbolo de una tabla estatica dada una posicion
char* regresaSimbolo(const char **arr, char posicion){
    return arr[posicion];
}

//Insertar cadena en la lista de tokens para cadenas que pertenecen a una tabla estatica
void insertarToken( ptrNodoLista *ptrS, char clase, char posicion){
  ptrNodoLista ptrNuevo;
  ptrNodoLista ptrAnterior;
  ptrNodoLista ptrActual;

  ptrNuevo = malloc(sizeof(NodoLista));

  if( ptrNuevo != NULL ){
    ptrNuevo->clase = clase;
    ptrNuevo->posicion = posicion;
    ptrNuevo->ptrSig = NULL;

    ptrAnterior = NULL;
    ptrActual = *ptrS;

    while( ptrActual != NULL ){
      ptrAnterior = ptrActual;
      ptrActual = ptrActual->ptrSig;
    }

    if ( ptrAnterior == NULL ){
      ptrNuevo->ptrSig = *ptrS;
      *ptrS = ptrNuevo;
    }
    else{
      ptrAnterior->ptrSig = ptrNuevo;
      ptrNuevo->ptrSig = ptrActual;
    }
  }
  else{
    printf("No se inserto el valor\n");
  }
}

void imprimeListaToken( ptrNodoLista ptrActual ){
  char *tmp;

  if ( ptrActual == NULL) {
    printf("La lista esta vacia\n");
  }
  else{
    printf("\nTokens:\n");
    while(ptrActual != NULL){
      if(ptrActual->clase == 4 || ptrActual->clase == 5){
        if(ptrActual->clase == 4){
          tmp = regresaSimbolo(op.opArit, ptrActual->posicion);
          printf("(%d, %c)\n", (ptrActual->clase), tmp[0] );
        }
        else{
          tmp = regresaSimbolo(op.simbEsp, ptrActual->posicion);
          printf("(%d, %c)\n", (ptrActual->clase), tmp[0] );
        }
      }
      else
        printf("(%d, %d)\n", (ptrActual->clase), (ptrActual->posicion) );
      ptrActual = ptrActual->ptrSig;
    }
    printf("NULL\n");
  }
}

//Inserta cadenas en la lista dinamica generada por el analizador
void insertar( ptrNodoListaExpandible *ptrS, char *elemento, char clase){
  ptrNodoListaExpandible ptrNuevo;
  ptrNodoListaExpandible ptrAnterior;
  ptrNodoListaExpandible ptrActual;

  ptrNuevo = malloc(sizeof(NodoListaExpandible));

  if( ptrNuevo != NULL ){
    strncpy(ptrNuevo->elemento, elemento, strlen(elemento));
    ptrNuevo->clase = clase;
    ptrNuevo->ptrSig = NULL;

    ptrAnterior = NULL;
    ptrActual = *ptrS;

    while( ptrActual != NULL ){
      ptrAnterior = ptrActual;
      ptrActual = ptrActual->ptrSig;
    }

    if ( ptrAnterior == NULL ){
      ptrNuevo->ptrSig = *ptrS;
      *ptrS = ptrNuevo;
    }
    else{
      ptrAnterior->ptrSig = ptrNuevo;
      ptrNuevo->ptrSig = ptrActual;
    }
  }
  else{
    printf("No se inserto el valor\n");
  }
}

void imprimeLista( ptrNodoListaExpandible ptrActual ){
  char pos = 0;

  if ( ptrActual == NULL) {
    printf("La lista esta vacia\n");
  }
  else{
    while(ptrActual != NULL){
      if( ptrActual->clase == 1 || ptrActual->clase == 6){
          if( ptrActual->clase == 1 )
            printf("(%d, %s, )\n", pos++, (ptrActual->elemento) );
          else
            printf("(%d, %s)\n", pos++, (ptrActual->elemento) );
      }
      else
        printf("(%d, %s)\n", (ptrActual->clase), (ptrActual->elemento) );
      ptrActual = ptrActual->ptrSig;
    }
    printf("NULL\n");
  }
}

//Convierte las listas a archivos dandole el formato solicitado
void lista2ArchivoToken(ptrNodoLista ptrInicial, FILE *fp){
  char *tmp;
  fprintf(fp, "Tokens de tablas estaticas:\n");
  while(ptrInicial != NULL){
    if(ptrInicial->clase == 4 || ptrInicial->clase == 5){
      if(ptrInicial->clase == 4){
        tmp = regresaSimbolo(op.opArit, ptrInicial->posicion);
        fprintf(archSalida, "(%d, %c)\n", (ptrInicial->clase), tmp[0] );
      }
      else{
        tmp = regresaSimbolo(op.simbEsp, ptrInicial->posicion);
        fprintf(archSalida, "(%d, %c)\n", (ptrInicial->clase), tmp[0] );
      }
    }
    else
      fprintf(archSalida, "(%d, %d)\n", ptrInicial->clase, ptrInicial->posicion);
    ptrInicial = ptrInicial->ptrSig;
  }
}

void lista2Archivo(ptrNodoListaExpandible ptrActual, char *titulo, FILE *fp){
  char pos = 0;

  fprintf(fp, "%s\n", titulo);
  while(ptrActual != NULL){
    if( ptrActual->clase == 1 || ptrActual->clase == 6 || ptrActual->clase == 9){
        if( ptrActual->clase == 1 )
          fprintf(fp, "(%d, %s, )\n", pos++, (ptrActual->elemento) );
        else
          fprintf(fp, "(%d, %s)\n", pos++, (ptrActual->elemento) );
    }
    else
      fprintf(archSalida, "(%d, %s)\n", ptrActual->clase, ptrActual->elemento);
    ptrActual = ptrActual->ptrSig;
  }
  fprintf(archSalida, "\n");
}
