grammar edu:umn:cs:melt:exts:ableC:constructor:abstractsyntax;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;

production newExpr
top::Expr ::= id::Name args::Exprs
{
  top.pp = pp"new ${id.pp}(${ppImplode(pp", ", args.pps)})";
  id.env = top.env;

  local fwrdProd::Constructor =
    case lookupConstructor(id.name, top.env) of
    | [] -> bindConstructor(errorExpr([errFromOrigin(id, s"Undefined constructor ${id.name}")]))
    | [c] -> c
    | _ :: _ -> bindConstructor(errorExpr([errFromOrigin(id, s"Ambiguous constructor ${id.name}")]))
    end;
  
  forwards to fwrdProd(@args);
}

dispatch Constructor = Expr ::= args::Exprs;

production bindConstructor implements Constructor
top::Expr ::= args::Exprs result::Expr
{
  forwards to letExpr(
    consDecl(bindExprsDecls(freshName("a"), @args), nilDecl()),
    @result);
}

production callConstructor implements Constructor
top::Expr ::= args::Exprs fn::Expr
{
  forwards to callExpr(@fn, @args);
}

production deleteStmt
top::Stmt ::= e::Expr
{
  top.pp = pp"delete ${e.pp};";
  top.functionDefs := [];
  top.labelDefs := [];

  propagate env, controlStmtContext;
  
  local localErrors::[Message] =
    case e.typerep, e.typerep.deleteProd of
    | errorType(), _ -> []
    | _, just(prod) -> []
    | t, nothing() -> [errFromOrigin(e, s"delete operator is not defined for type ${show(80, t)}")]
    end;
  
  local fwrdProd::Destructor =
    case e.typerep, e.typerep.deleteProd of
    | errorType(), _ -> bindDestructor(errorExpr([]))
    | t, nothing() ->
      bindDestructor(errorExpr([errFromOrigin(e, s"delete operator is not defined for type ${show(80, t)}")]))
    | _, just(prod) -> prod
    end;
  
  forwards to exprStmt(fwrdProd(@e));
}

dispatch Destructor = Expr ::= e::Expr;

production bindDestructor implements Destructor
top::Expr ::= e::Expr result::Expr
{
  forwards to letExpr(
    consDecl(bindExprDecl(freshName("a"), @e), nilDecl()),
    @result);
}

production callDestructor implements Destructor
top::Expr ::= e::Expr fn::Expr
{
  forwards to callExpr(@fn, consExpr(@e, nilExpr()));
}

synthesized attribute deleteProd::Maybe<Destructor> occurs on Type, ExtType;
flowtype deleteProd {decorate} on Type, ExtType;

aspect default production
top::Type ::=
{
  top.deleteProd = nothing();
}

aspect production extType
top::Type ::= q::Qualifiers  sub::ExtType
{
  top.deleteProd = sub.deleteProd;
}

aspect default production
top::ExtType ::=
{
  top.deleteProd = nothing();
}
