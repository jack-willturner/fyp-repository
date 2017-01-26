%{
  open Ast
%}

(***** DATA TYPES *****)
%token  <string>  STRING
%token  <int>     INT

(****** TOKENS ******)
%token IDENTITY
%token TENSOR
%token OPEN_SQUARE CLOSE_SQUARE
%token OPEN_BRACE CLOSE_BRACE
%token BOX LINK
%token MODULE
%token DOT COMMA BAR COLON ARROW SEMICOLON
%token INPUTS
%token EOF

(***** PRECEDENCE RULES *****)
%left  BAR
%left  SEMICOLON

(***** PARSING RULES *****)
%start <Ast.program> top
%%

morphism_def:
  | BOX; morphism_id = STRING; COLON;
     inputs=STRING; ARROW; outputs=STRING;

    {Box(morphism_id, (int_of_string inputs), (int_of_string outputs))}

wire_def:
  | from_exp = STRING; to_exp = STRING;   {Wire(from_exp, to_exp)}

params:
  | OPEN_SQUARE; params = separated_list(COMMA, STRING); CLOSE_SQUARE;     {params}

diagram:
  | IDENTITY                                {Identity}
  | ins = option(params); morphID = STRING; outs = option(params)  {Morphism(morphID, ins, outs)}
  | d1 = diagram; SEMICOLON; d2 = diagram   {Composition(d1, d2)}
  | e=diagram;    BAR;  f = diagram         {Tensor (e,f)}


module_def :
  | MODULE; m_name = STRING; OPEN_BRACE; b_list = separated_list(DOT,morphism_def);
    LINK; w_list = separated_list(COMMA,wire_def); DOT;
    d = diagram; CLOSE_BRACE;               {Module(m_name, b_list, w_list, d)}

definition:
  | m_list = separated_list(DOT,morphism_def);
    LINK; w_list = separated_list(COMMA,wire_def); DOT;
    d = diagram;                            {Diagram(m_list, w_list, d)}

top:
  | module_list = list(module_def); definition_list = list(definition); EOF  {Program(module_list, definition_list)}
