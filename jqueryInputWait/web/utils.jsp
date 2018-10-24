<%@page import="java.util.UUID"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%!
    public static boolean isSet(String request) {
        boolean ret = false;
        if (request != null && request.isEmpty() == false) {
            ret = true;
        }
        return ret;
    }

    public static String base64encode(byte[] data) {
        char[] tbl = {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
            'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
            'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'};

        StringBuilder buffer = new StringBuilder();
        int pad = 0;
        for (int i = 0; i < data.length; i += 3) {

            int b = ((data[i] & 0xFF) << 16) & 0xFFFFFF;
            if (i + 1 < data.length) {
                b |= (data[i + 1] & 0xFF) << 8;
            } else {
                pad++;
            }
            if (i + 2 < data.length) {
                b |= (data[i + 2] & 0xFF);
            } else {
                pad++;
            }

            for (int j = 0; j < 4 - pad; j++) {
                int c = (b & 0xFC0000) >> 18;
                buffer.append(tbl[c]);
                b <<= 6;
            }
        }
        for (int j = 0; j < pad; j++) {
            buffer.append("=");
        }

        return buffer.toString();
    }

    public static byte[] base64decode(String data) {
        int[] tbl = {
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54,
            55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2,
            3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
            20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30,
            31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
            48, 49, 50, 51, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
        byte[] bytes = data.getBytes();
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        for (int i = 0; i < bytes.length;) {
            int b = 0;
            if (tbl[bytes[i]] != -1) {
                b = (tbl[bytes[i]] & 0xFF) << 18;
            } // skip unknown characters
            else {
                i++;
                continue;
            }

            int num = 0;
            if (i + 1 < bytes.length && tbl[bytes[i + 1]] != -1) {
                b = b | ((tbl[bytes[i + 1]] & 0xFF) << 12);
                num++;
            }
            if (i + 2 < bytes.length && tbl[bytes[i + 2]] != -1) {
                b = b | ((tbl[bytes[i + 2]] & 0xFF) << 6);
                num++;
            }
            if (i + 3 < bytes.length && tbl[bytes[i + 3]] != -1) {
                b = b | (tbl[bytes[i + 3]] & 0xFF);
                num++;
            }

            while (num > 0) {
                int c = (b & 0xFF0000) >> 16;
                buffer.write((char) c);
                b <<= 8;
                num--;
            }
            i += 4;
        }
        return buffer.toByteArray();
    }

    public static class Data {

        private java.sql.ResultSet rs = null;
        private Statement statement = null;

        Data(Statement statement, java.sql.ResultSet rs) {
            this.statement = statement;
            this.rs = rs;
        }

        public boolean get() throws Exception {
            return rs.next();
        }

        public java.sql.ResultSet getResultSet() {
            return rs;
        }

        public Statement getStatement() {
            return statement;
        }

        public String getString(int field) throws Exception {
            return rs.getString(field);
        }

        public String getString(String field) throws Exception {
            return rs.getString(field);
        }

        public int getInt(int field) throws Exception {
            return rs.getInt(field);
        }

        public int getInt(String field) throws Exception {
            return rs.getInt(field);
        }

        public long getLong(int field) throws Exception {
            return rs.getLong(field);
        }

        public long getLong(String field) throws Exception {
            return rs.getLong(field);
        }

        public void close() {
            try {
                rs.close();
                statement.close();
            } catch (Exception e) {

            }
        }
    }

    public static Connection getNewConnection() throws Exception {
        Class.forName("com.informix.jdbc.IfxDriver");
        //return DriverManager.getConnection("jdbc:informix-sqli://172.16.0.37:1526/hospital:INFORMIXSERVER=hpc2016des", "informix", "leia");
        return DriverManager.getConnection("jdbc:informix-sqli://129.1.0.10:1525/hospital:INFORMIXSERVER=hpc", "informix", "quake3");
    }

    public static String toUTF(String texto) {
        String res = texto;
        try {
            res = new String(texto.getBytes("ISO-8859-1"), "UTF-8");
        } catch (Exception e) {

        }
        return res;
    }

    public static String getUUID(int length) {
        String res = "";
        res = UUID.randomUUID().toString().replaceAll("-", "").substring(0, length);
        return res;
    }

    public static Data getData(Connection connection, String sql) throws Exception {
        Statement statement = connection.createStatement();
        return new Data(statement, statement.executeQuery(sql));
    }

    public static String getString(Connection connection, String sql) throws Exception {
        String res = "";
        Statement statement = connection.createStatement();
        java.sql.ResultSet rs = statement.executeQuery(sql);
        if (rs.next()) {
            res = rs.getString(1);
        }
        rs.close();
        statement.close();
        return res;
    }

    public static void setData(Connection connection, String sql) throws Exception {
        Statement statement = connection.createStatement();
        statement.executeUpdate(sql);
        statement.close();
    }

    public static void closeConnection(Connection c) throws Exception {
        if (c != null && c.isClosed() == false) {
            c.close();
        }
    }

    public static String isNull(String... texto) {
        String res = "";
        if (texto[0] != null && texto[0].isEmpty() == false) {
            res = texto[0].trim();
        } else {
            if (texto.length > 1) {
                res = texto[1];
            }
        }
        return res;
    }

    public static String toFecha(String fecha, String formatoViejo, String formatoNuevo) {
        String f = fecha;
        try {
            f = new SimpleDateFormat(formatoNuevo).format(new SimpleDateFormat(formatoViejo).parse(fecha).getTime());
        } catch (Exception e) {
            System.out.println(e.toString());
        }
        return f;
    }

    public static double similarity(String s1, String s2) {
        String longer = s1, shorter = s2;
        if (s1.length() < s2.length()) {
            longer = s2;
            shorter = s1;
        }
        int longerLength = longer.length();
        if (longerLength == 0) {
            return 1.0;
        }
        return (longerLength - editDistance(longer, shorter)) / (double) longerLength;
    }

    public static int editDistance(String s1, String s2) {
        s1 = s1.toLowerCase();
        s2 = s2.toLowerCase();

        int[] costs = new int[s2.length() + 1];
        for (int i = 0; i <= s1.length(); i++) {
            int lastValue = i;
            for (int j = 0; j <= s2.length(); j++) {
                if (i == 0) {
                    costs[j] = j;
                } else {
                    if (j > 0) {
                        int newValue = costs[j - 1];
                        if (s1.charAt(i - 1) != s2.charAt(j - 1)) {
                            newValue = Math.min(Math.min(newValue, lastValue),
                                    costs[j]) + 1;
                        }
                        costs[j - 1] = lastValue;
                        lastValue = newValue;
                    }
                }
            }
            if (i > 0) {
                costs[s2.length()] = lastValue;
            }
        }
        return costs[s2.length()];
    }

    public static int computeDistance(String s1, String s2) {
        s1 = s1.toLowerCase();
        s2 = s2.toLowerCase();
        if (s1.length() > s2.length()) {
            String aux = s1;
            s1 = s2;
            s2 = aux;
        }

        int[] costs = new int[s2.length() + 1];
        for (int i = 0; i <= s1.length(); i++) {
            int lastValue = i;
            for (int j = 0; j <= s2.length(); j++) {
                if (i == 0) {
                    costs[j] = j;
                } else {
                    if (j > 0) {
                        int newValue = costs[j - 1];
                        if (s1.charAt(i - 1) != s2.charAt(j - 1)) {
                            newValue = Math.min(Math.min(newValue, lastValue), costs[j]) + 1;
                        }
                        costs[j - 1] = lastValue;
                        lastValue = newValue;
                    }
                }
            }
            if (i > 0) {
                costs[s2.length()] = lastValue;
            }
        }
        return costs[s2.length()];
    }
%>