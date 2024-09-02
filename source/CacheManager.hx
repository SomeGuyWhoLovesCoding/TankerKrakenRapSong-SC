// This helper is bullshit

package;

import openfl.Assets;
import openfl.utils.AssetCache;
import openfl.utils.IAssetCache;

class CacheManager {
    public static var cache:Map<String, String>;

    public function new() {
        cache = new Map<String, String>();
    }

    public static function start() {
        Assets.cache.enabled = true;
        trace('Cache started!');
    }

    public static function set(id:String) {
        cache.set(id, id);
    }
}