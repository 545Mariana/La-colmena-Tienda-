<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Crear Cuenta</title>
</head>
<body>

<h2 align="center">Crear Cuenta</h2>

<!-- se hace el insert cuando se pulsa crear -->
<c:if test="${param.accion == 'crear'}">

    <!-- esto es para restringir que puedan dejarse campos vacio y twner NUll  -->
    <c:if test="${
        not empty param.nombre and
        not empty param.apellido_paterno and
        not empty param.apellido_materno and
        not empty param.contrasena and
        not empty param.domicilio and
        not empty param.codigo_postal and
        not empty param.num_telefonico and
        not empty param.tarjeta_credito and
        not empty param.fecha_expiracion
    }">
        <c:catch var="err">
            <sql:update dataSource="jdbc/TestDS">
                INSERT INTO cliente
                (nombre, apellido_paterno, apellido_materno, contrasena, domicilio, codigo_postal, num_telefonico, tarjeta_credito, fecha_expiracion)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                <sql:param value="${param.nombre}" />
                <sql:param value="${param.apellido_paterno}" />
                <sql:param value="${param.apellido_materno}" />
                <sql:param value="${param.contrasena}" />
                <sql:param value="${param.domicilio}" />
                <sql:param value="${param.codigo_postal}" />
                <sql:param value="${param.num_telefonico}" />
                <sql:param value="${param.tarjeta_credito}" />
                <sql:param value="${param.fecha_expiracion}" />
            </sql:update>
        </c:catch>

        <c:if test="${empty err}">
            <p align="center" style="color:green;">Cuenta creada</p>
        </c:if>>
    </c:if>

    <!-- esto es para que se llene todos los campos -->
    <c:if test="${
        empty param.nombre or
        empty param.apellido_paterno or
        empty param.apellido_materno or
        empty param.contrasena or
        empty param.domicilio or
        empty param.codigo_postal or
        empty param.num_telefonico or
        empty param.tarjeta_credito or
        empty param.fecha_expiracion
    }">
        <p align="center" style="color:red;">❌ Debes llenar todos los campos</p>
    </c:if>

</c:if>

<!-- formulario para llenar el resgistro de nuevo-->
<form method="post" action="${pageContext.request.requestURI}">
    <input type="hidden" name="accion" value="crear">

    <table align="center" border="0" cellpadding="1" cellspacing="10" width="800">

        <tr>
            <td align="right">Nombre(s):</td>
            <td><input name="nombre" value="${param.nombre}"></td>
        </tr>

        <tr>
            <td align="right">Apellido Paterno:</td>
            <td><input name="apellido_paterno" value="${param.apellido_paterno}"></td>
        </tr>

        <tr>
            <td align="right">Apellido Materno:</td>
            <td><input name="apellido_materno" value="${param.apellido_materno}"></td>
        </tr>

        <tr>
            <td align="right">Contraseña:</td>
            <td><input name="contrasena" value="${param.contrasena}"></td>
        </tr>

        <tr>
            <td align="right">Domicilio:</td>
            <td><input name="domicilio" value="${param.domicilio}"></td>

            <td align="right">Codigo Postal:</td>
            <td><input name="codigo_postal" value="${param.codigo_postal}"></td>
        </tr>

        <tr>
            <td align="right">Num. Telefonico:</td>
            <td><input name="num_telefonico" value="${param.num_telefonico}"></td>
        </tr>

        <tr>
            <td align="right">Tarjeta de Credito:</td>
            <td><input name="tarjeta_credito" value="${param.tarjeta_credito}"></td>

            <td align="right">Fecha de Expiracion:</td>
            <td><input name="fecha_expiracion" value="${param.fecha_expiracion}"></td>
        </tr>

        <tr>
            <td align="center" colspan="4">
                <input value="Crear Cuenta" type="submit">
            </td>
        </tr>

        <tr>
            <td align="center" colspan="4">
                <input value="Regresar" type="button" onclick="history.back();">
            </td>
        </tr>

    </table>
</form>

</body>
</html>
