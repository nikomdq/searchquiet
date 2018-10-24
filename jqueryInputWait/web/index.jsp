<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="jquery-3.2.0.js" type="text/javascript"></script>
        <title>JSP Page</title>
        <script>
            var SearchQuiet = function (args) {
                var waitTime = args.wt || 500;
                var i = $(args.input);
                var este = this;
                var lastVal = null;
                var interval = null;

                i.unbind("keyup");

                i.bind("keyup", function () {
                    var valor = $(this).val();
                    if (lastVal !== valor) {
                        if (typeof args.searchstart !== "undefined" && $.trim(valor).length > 0) {
                            args.searchstart();
                        }
                        if (interval !== null) {
                            clearInterval(interval);
                        }

                        interval = setTimeout(function () {
                            args.searchend(valor);
                        }, waitTime);
                        lastVal = valor;
                    }
                });
            };

            $(function () {
                new SearchQuiet({
                    input: "#busqueda",
                    searchstart: function () {
                        $("#estado").html("Buscando");
                    },
                    searchend: function (val) {
                        $("#estado").html("Preparando información");
                        if ($.trim(val).length > 0) {
                            $.ajax({
                                url: "gethc.jsp",
                                data: {val: val},
                                beforeSend: function () {},
                                complete: function () {
                                    $("#estado").html("Completado");
                                },
                                success: function (data) {
                                    $("table").html(data);
                                }
                            });
                        } else
                        {
                            $("#estado").html("Completado");
                        }
                    }
                });
            });
        </script>
    </head>
    <body>
        <input type="text" id="busqueda" /> 
        <div id='estado'></div>
        <table></table>
    </body>
</html>
