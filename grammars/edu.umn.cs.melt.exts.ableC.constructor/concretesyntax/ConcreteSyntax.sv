grammar edu:umn:cs:melt:exts:ableC:constructor:concretesyntax;

imports silver:langutil;

imports edu:umn:cs:melt:ableC:concretesyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:exts:ableC:constructor:abstractsyntax;

marking terminal New_t 'new' lexer classes {Keyword, Global};
marking terminal Delete_t 'delete' lexer classes {Keyword, Global};

concrete production newExpr_c
top::PrimaryExpr_c ::= 'new' sqs::SpecifierQualifierList_c '(' args::ArgumentExprList_c ')'
{
  sqs.givenQualifiers = sqs.typeQualifiers;
  local bt::BaseTypeExpr =
    figureOutTypeFromSpecifiers(sqs.typeQualifiers, sqs.preTypeSpecifiers, sqs.realTypeSpecifiers, sqs.mutateTypeSpecifiers);
  top.ast =
    newExpr(
      typeName(
        case decorate sqs.attributes with { controlStmtContext = initialControlStmtContext; } of
        | nilAttribute() -> bt
        | _ -> warnTypeExpr([wrnFromOrigin(top, "Ignoring attributes in new type expression")], bt)
        end,
        baseTypeExpr()),
      foldExpr(args.ast));
}

concrete production newExprNoArgs_c
top::PrimaryExpr_c ::= 'new' sqs::SpecifierQualifierList_c '(' ')'
{
  sqs.givenQualifiers = sqs.typeQualifiers;
  local bt::BaseTypeExpr =
    figureOutTypeFromSpecifiers(sqs.typeQualifiers, sqs.preTypeSpecifiers, sqs.realTypeSpecifiers, sqs.mutateTypeSpecifiers);
  top.ast =
    newExpr(
      typeName(
        case decorate sqs.attributes with { controlStmtContext = initialControlStmtContext; } of
        | nilAttribute() -> bt
        | _ -> warnTypeExpr([wrnFromOrigin(top, "Ignoring attributes in new type expression")], bt)
        end,
        baseTypeExpr()),
      nilExpr());
}

concrete production deleteStmt_c
top::Stmt_c ::= 'delete' e::Expr_c ';'
{
  top.ast = deleteStmt(e.ast);
}
