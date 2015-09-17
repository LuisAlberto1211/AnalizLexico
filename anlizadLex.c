/*
  Ortega Vazquez Luis Alberto
  Compiladores
  Profesora: Laura Sandoval Montaño
  Descripcion:
    El programa tiene como finalidad identificar los operadores manejados por C(relacionales,
    asignacion, aritmeticos y logicos).
    A partir de la identificacion se generara un token que indicara la clase de elemento
    identificado y su posicion dentro de su correspondiente tabla.
    Las tablas a generar son las siguientes:
      > Tabla de simbolos
      > Tabla de cadenas
    Las tablas estáticas que tendrá el programa son:
      > Tabla de palabras reservadas
      > Operadores relacionales = { >, >=, <, <=, ==, != }
      > Operadores de asignacion = { =, +=, -=, *=, /=, %=, >>=, <<=, ^=, &=, \= }
      > Operadores aritmeticos = { +, - , *, /, % }
      > Operadores logicos = { &&, \\, ! }
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Longitud maxima de cada simbolo perteneciente a una tabla de operadores
#define LONG_MAX_SYM 3
#define LONG_MAX_STR 16

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
  const char *palRes[SIMB_PALRES];
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
  struct nodoListaExpandible *ptrSig;
};

typedef struct nodoListaExpandible NodoListaExpandible;
typedef NodoListaExpandible *ptrNodoListaExpandible;

//Funciones para el manejo de la lista ligada TOKENS
void insertar( ptrNodoLista *ptrS, char clase, char posicion);
void imprimeLista( ptrNodoLista ptrActual );

//Funciones para el manejo de la lista ligada EXPANDIBLE
void insertar( ptrNodoListaExpandible *ptrS, char *elemento);
void imprimeLista( ptrNodoListaExpandible ptrActual );


//Funcion principal
int main(int argc, char const *argv[]) {
  char i, j;
  ptrNodoLista ptrInicialTokens = NULL; //Nodo inicial de la lista ligada de tokens
  ptrNodoListaExpandible ptrInicial = NULL; //Nodo inicial de la lista ligada expandible

  char c[LONG_MAX_STR]; //Almacenara las cadenas que se leen del archivo (longitud maxima 16)

  Operadores op = { SIMB_PALRES, SIMB_REL, SIMB_ASIG, SIMB_ARIT, SIMB_ESP};  //Se inicializa las tablas de operadores

  if((fp = fopen(argv[1], "r")) == NULL){
    printf("No pudo abrirse el archivo\n");
  }else{
    while( !feof(fp) ){
      fscanf(fp, "%s", c);  //Lectura de cada palabra en el archivo
      //printf("%s: ", c);

      //Busqueda del operador
      for( i = 4; i <= 7; i++){
        switch (i){
          case 4:
            j = buscaElemento(op.opRel, c, SIMB_REL_NUM); //Operadores relacionales
            break;
          case 5:
            j = buscaElemento(op.opAsig, c, SIMB_ASIG_NUM); //Operdores de asignacion
            break;
          case 6:
            j = buscaElemento(op.opArit, c, SIMB_ARIT_NUM); //Operadores aritmeticos
            break;
          case 7:
            j = buscaElemento(op.opLog, c, SIMB_LOG_NUM); //Operadores logicos
            break;
        }

        //Si encuentra el operador lo inserta en la lista para generar su token
        if( j != -1){
            //printf("Simbolo: %s, Token(%d: %d)\n", c, i, j);
            insertar(&ptrInicial, i, j);
            break;
        }
      }
      //En caso de no encontrar coincidencias en las tablas se muestra un mensaje de error
      if (j == -1){
        printf("Simbolo: \"%s\", no pertenece al lenguaje\n", c);
      }
    }
    fclose(fp);
    imprimeLista(ptrInicial); //Muestra la lista de tokens
  }

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

void insertar( ptrNodoLista *ptrS, char clase, char posicion){
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

void imprimeLista( ptrNodoLista ptrActual ){
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

void insertar( ptrNodoListaExpandible *ptrS, char *elemento){
  ptrNodoListaExpandible ptrNuevo;
  ptrNodoListaExpandible ptrAnterior;
  ptrNodoListaExpandible ptrActual;

  ptrNuevo = malloc(sizeof(NodoLista));

  if( ptrNuevo != NULL ){
    ptrNuevo->elemento = elemento;
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
      printf("%s\n", (ptrActual->elemento) );
      ptrActual = ptrActual->ptrSig;
    }
    printf("NULL\n");
  }
}
