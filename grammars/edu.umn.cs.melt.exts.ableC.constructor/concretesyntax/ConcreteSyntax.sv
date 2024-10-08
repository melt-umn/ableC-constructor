grammar edu:umn:cs:melt:exts:ableC:constructor:concretesyntax;

imports silver:langutil;

imports edu:umn:cs:melt:ableC:concretesyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:exts:ableC:constructor:abstractsyntax;

marking terminal New_t 'new' lexer classes {Keyword, Global};
marking terminal Delete_t 'delete' lexer classes {Keyword, Global};

concrete productions top::PrimaryExpr_c
| 'new' id::Identifier_c '(' args::ArgumentExprList_c ')'
  { top.ast = newExpr(id.ast, foldExpr(args.ast)); }
| 'new' id::Identifier_c '(' ')'
  { top.ast = newExpr(id.ast, nilExpr()); }
| 'new' id::TypeIdName_c '(' args::ArgumentExprList_c ')'
  { top.ast = newExpr(id.ast, foldExpr(args.ast)); }
| 'new' id::TypeIdName_c '(' ')'
  { top.ast = newExpr(id.ast, nilExpr()); }

concrete production deleteStmt_c
top::Stmt_c ::= 'delete' e::Expr_c ';'
{
  top.ast = deleteStmt(e.ast);
}
