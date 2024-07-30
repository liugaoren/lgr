

import java.math.BigDecimal;
import java.math.RoundingMode;


public class CoordinateUtil {

    private static final Double PI = 3.14159265358979324;
    private static final Double X_PI = 3.14159265358979324 * 3000.0 / 180.0;

    private static double EARTH_RADIUS = 6371.393;
    private static double rad(double d)
    {
        return d * Math.PI / 180.0;
    }


    /**
     * 计算两个经纬度之间的距离
     * @param lat1 第一个纬度
     * @param lng1 第一个经度
     * @param lat2 第二个纬度
     * @param lng2 第二个经度
     * @return 两个经纬度之间的距离
     */
    public static double getDistance(double lng1, double lat1, double lng2, double lat2)
    {
        double radLat1 = rad(lat1);
        double radLat2 = rad(lat2);
        double a = radLat1 - radLat2;
        double b = rad(lng1) - rad(lng2);
        double s = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a/2),2) +
                Math.cos(radLat1)*Math.cos(radLat2)*Math.pow(Math.sin(b/2),2)));
        s = s * EARTH_RADIUS;
        if(s<1){
            BigDecimal bigDecimal = new BigDecimal(s).setScale(2, RoundingMode.HALF_UP);
            return  bigDecimal.doubleValue();
        }else{
            return  Math.round(s);
        }
    }

    public static double getDistanceMi(double lng1, double lat1, double lng2, double lat2)
    {
        double radLat1 = rad(lat1);
        double radLat2 = rad(lat2);
        double a = radLat1 - radLat2;
        double b = rad(lng1) - rad(lng2);
        double s = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a/2),2) +
                Math.cos(radLat1)*Math.cos(radLat2)*Math.pow(Math.sin(b/2),2)));
        s = s * EARTH_RADIUS;
        return   Math.round(s*1000);
    }

    /**
     * GCJ-02 to WGS-84
     * @param longitude 经度
     * @param latitude 纬度
     * @return
     */
    public static CoordinateVo gcjTrans84(double longitude, double latitude){
        CoordinateVo coordinate = delta(longitude,latitude);
        coordinate.setLongitude(longitude-coordinate.getLongitude());
        coordinate.setLatitude(latitude - coordinate.getLatitude());
        return  coordinate;
    }

    /**
     *  WGS-84 to GCJ-02
     * @param longitude 经度
     * @param latitude 纬度
     * @return
     */
    public static CoordinateVo criterionToGcj(double longitude, double latitude){
        CoordinateVo coordinate = delta(longitude,latitude);
        coordinate.setLongitude(longitude + coordinate.getLongitude());
        coordinate.setLatitude(latitude + coordinate.getLatitude());
        return  coordinate;
    }

    /**
     * bd-09(百度) 转 GCJ-02
     * @param longitude 经度
     * @param latitude 纬度
     * @return
     */
    public static CoordinateVo bdToGcj(double longitude, double latitude){
        CoordinateVo coordinate = new CoordinateVo();
        double x = longitude - 0.0065;
        double y = latitude -  0.006;

        double z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * X_PI);
        double theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * X_PI);
        coordinate.setLongitude(z * Math.cos(theta));
        coordinate.setLatitude(z * Math.sin(theta));
        return coordinate;
    }


    /**
     * bd-09(百度) 转 84
     * @param longitude
     * @param latitude
     * @return
     */
    public static CoordinateVo bdTo84(double longitude, double latitude){
        CoordinateVo coordinate = CoordinateUtil.bdToGcj(longitude,latitude);
        if(coordinate!=null){
            return  CoordinateUtil.gcjTrans84(coordinate.getLongitude(),coordinate.getLatitude());
        }
        return null;
    }


    /**
     * 计算两点之间的角度
     * @param statLng 开始经度
     * @param startLat 开始纬度
     * @param endLng 结束经度
     * @param endLat 结束纬度
     * @return 角度
     */
    public static Double getAngle(Double statLng,Double startLat,Double endLng,Double endLat){
        Double atan = Math.atan2((endLng-statLng),(endLat-startLat));
        Double angle = (atan * 180/Math.PI);
        if(atan<0){
            angle = (atan * 180 / Math.PI) + 360;
        }
        return  angle;
    }

    /**
     * 计算弧度
     * @return
     */
    public static Double getRotation(Double angle){
        return (angle * Math.PI) / 180;
    }

    public static CoordinateVo delta(double longitude, double latitude ){
        //卫星椭球坐标投影到平面地图坐标系的投影因子。
        double a = 6378245.0;

        //  ee: 椭球的偏心率。
        double ee = 0.00669342162296594323;

        double dLat = transformLat(longitude - 105.0, latitude - 35.0);
        double dLon = transformLon(longitude - 105.0, latitude - 35.0);

        double radLat = latitude / 180.0 * PI;
        double magic = Math.sin(radLat);
        magic = 1 - ee * magic * magic;
        double sqrtMagic = Math.sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * PI);
        dLon = (dLon * 180.0) / (a / sqrtMagic * Math.cos(radLat) * PI);
        CoordinateVo result = new CoordinateVo();
        result.setLongitude(dLon);
        result.setLatitude(dLat);
        return  result;
    }

    private static double transformLat(double x,double y){
        double ret =  -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.sqrt(Math.abs(x));
        ret += (20.0 * Math.sin(6.0 * x * PI) + 20.0 * Math.sin(2.0 * x * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(y * PI) + 40.0 * Math.sin(y / 3.0 * PI)) * 2.0 / 3.0;
        ret += (160.0 * Math.sin(y / 12.0 * PI) + 320 * Math.sin(y * PI / 30.0)) * 2.0 / 3.0;
        return ret;
    }

    private static double transformLon(double x,double y){
        double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.sqrt(Math.abs(x));
        ret += (20.0 * Math.sin(6.0 * x * PI) + 20.0 * Math.sin(2.0 * x * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(x * PI) + 40.0 * Math.sin(x / 3.0 * PI)) * 2.0 / 3.0;
        ret += (150.0 * Math.sin(x / 12.0 * PI) + 300.0 * Math.sin(x / 30.0 * PI)) * 2.0 / 3.0;
        return ret;
    }


}
