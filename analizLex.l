%{
  #include <stdio.h>
  #include <stdlib.h>

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
  //Simbolos de cada tabla de operador
  #define SIMB_REL { ">", ">=", "<", "<=", "=", "><" }
  #define SIMB_ASIG { ":=" }
  #define SIMB_ARIT { "+", "-", "*", "/"}
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
    char *elemento;
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

  int i, j;
  Operadores op = { SIMB_PALRES, SIMB_REL, SIMB_ASIG, SIMB_ARIT, SIMB_ESP};  //Se inicializa las tablas de operadores

  ptrNodoLista ptrInicialTokens = NULL;
  ptrNodoListaExpandible ptrInicial = NULL;

%}
palRes     _si|_sino|_finsi|_mientras|_finmientras|_haz|_desde|_hasta|_incremento
ident      [a-zA-Z]{1,16}
opAsig     :=
opRel      >=?|<=?|><|=
opArit     [\+\-*\/]
simbEsp    [\.,\(\)\[\]]
consCad    \".*\"
consEnt    (\+?|\-?)[0-9]+
sufijo     E{consEnt}
consReal   (({consEnt}?(.[0-9]+){sufijo}?)|(({consEnt}\.){sufijo}?))
comentario ¡.*!
espacio    [ \n\t]+
error      ([_:#$%&;{}?¿\\])+
%%
{palRes}      printf("Soy palRes %s\n", yytext);      j = buscaElemento(op.palRes, yytext, SIMB_PALRES_NUM); insertarToken(&ptrInicialTokens, 0, j);
{ident}       printf("Soy ident %s\n", yytext);
{opAsig}      printf("Soy opAsig %s\n", yytext);      j = buscaElemento(op.opAsig, yytext, SIMB_ASIG_NUM); insertarToken(&ptrInicialTokens, 2, j);
{opRel}       printf("Soy opRel %s\n", yytext);       j = buscaElemento(op.opRel, yytext, SIMB_REL_NUM); insertarToken(&ptrInicialTokens, 3, j);
{opArit}      printf("Soy opArit %s\n", yytext);      j = buscaElemento(op.opArit, yytext, SIMB_ARIT_NUM); insertarToken(&ptrInicialTokens, 4, j);
{simbEsp}     printf("Soy simbEsp %s\n", yytext);     j = buscaElemento(op.simbEsp, yytext, SIMB_ESP_NUM); insertarToken(&ptrInicialTokens, 5, j);
{consCad}     printf("Soy consCad %s\n", yytext);
{consEnt}     printf("Soy constEnt %s\n", yytext);
{sufijo}      printf("Soy sufijo %s\n", yytext);
{consReal}    printf("Soy consReal %s\n", yytext);
{comentario}  printf("Soy comentario %s\n", yytext);
{error}       printf("Soy error %s\n", yytext);
%%
int main(int argc, char *argv[]){

  yyin = fopen(argv[1], "r");
  yylex();
  fclose(yyin);

  imprimeListaToken(ptrInicialTokens);
  imprimeLista(ptrInicial);

  return 0;
}

int buscaElemento(const char **arr, char *symb, char tam){
  char i;
  for (i = 0; i < tam; i++){
    if(strncmp(arr[i], symb, LONG_MAX_SYM) == 0)
      return i;
  }
  return -1;
}


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
  if ( ptrActual == NULL) {
    printf("La lista esta vacia\n");
  }
  else{
    printf("\nTokens:\n");
    while(ptrActual != NULL){
      printf("(%d,%d)\n", (ptrActual->clase), (ptrActual->posicion) );
      ptrActual = ptrActual->ptrSig;
    }
    printf("NULL\n");
  }
}

void insertar( ptrNodoListaExpandible *ptrS, char *elemento, char clase){
  ptrNodoListaExpandible ptrNuevo;
  ptrNodoListaExpandible ptrAnterior;
  ptrNodoListaExpandible ptrActual;

  ptrNuevo = malloc(sizeof(NodoListaExpandible));

  if( ptrNuevo != NULL ){
    ptrNuevo->elemento = elemento;
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
  if ( ptrActual == NULL) {
    printf("La lista esta vacia\n");
  }
  else{
    printf("\nElementos:\n");
    while(ptrActual != NULL){
      printf("%s, clase: %d\n", (ptrActual->elemento), (ptrActual->clase) );
      ptrActual = ptrActual->ptrSig;
    }
    printf("NULL\n");
  }
}
