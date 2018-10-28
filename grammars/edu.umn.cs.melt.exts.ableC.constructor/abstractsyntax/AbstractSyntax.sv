grammar edu:umn:cs:melt:exts:ableC:constructor:abstractsyntax;

imports silver:langutil;
imports silver:langutil:pp;

imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:substitution;

synthesized attribute newProd::Maybe<(Expr ::= Exprs Location)> occurs on Type, ExtType;
flowtype newProd {decorate} on Type, ExtType;

synthesized attribute deleteProd::Maybe<(Stmt ::= Expr)> occurs on Type, ExtType;
flowtype deleteProd {decorate} on Type, ExtType;

aspect default production
top::Type ::=
{
  top.newProd = nothing();
  top.deleteProd = nothing();
}

aspect production extType
top::Type ::= q::Qualifiers  sub::ExtType
{
  top.newProd = sub.newProd;
  top.deleteProd = sub.deleteProd;
}

aspect default production
top::ExtType ::=
{
  top.newProd = nothing();
  top.deleteProd = nothing();
}

abstract production newExpr
top::Expr ::= ty::TypeName args::Exprs
{
  propagate substituted;
  top.pp = pp"new ${ty.pp}(${ppImplode(pp", ", args.pps)})";
  
  args.env = addEnv(ty.defs, top.env);
  
  local localErrors::[Message] =
    ty.errors ++ args.errors ++
    case ty.typerep, ty.typerep.newProd of
    | errorType(), _ -> []
    | _, just(prod) -> []
    | t, nothing() -> [err(top.location, s"new operator is not defined for type ${showType(t)}")]
    end;
  
  local fwrd::Expr =
    explicitCastExpr(
      ty,
      case ty.typerep of
      | errorType() -> errorExpr([], location=builtin)
      | t -> t.newProd.fromJust(args, top.location)
      end,
      location=builtin);
  
  forwards to mkErrorCheck(localErrors, fwrd);
}

abstract production deleteStmt
top::Stmt ::= e::Expr
{
  propagate substituted;
  top.pp = pp"delete ${e.pp};";
  top.functionDefs := [];
  
  local localErrors::[Message] =
    e.errors ++
    case e.typerep, e.typerep.deleteProd of
    | errorType(), _ -> []
    | _, just(prod) -> []
    | t, nothing() -> [err(e.location, s"delete operator is not defined for type ${showType(t)}")]
    end;
  
  local fwrd::Stmt =
    case e.typerep of
    | errorType() -> nullStmt()
    | t -> t.deleteProd.fromJust(e)
    end;
  
  forwards to if !null(localErrors) then warnStmt(localErrors) else fwrd;
}

global builtin::Location = builtinLoc("constructor");
