module Http2k
  module Helper
    # Builds the x2kafka config that replaces the n2kafka rb_http2k config.
    # The sensors_uuids enrichment becomes an enrichment_map keyed by sensor_uuid.
    def x2kafka_config(port, kafka_hosts, proxy_nodes, ips_nodes_list, locations_list)
      enrichment_map = {}

      ips_nodes_list.compact.each do |ips_nodes|
        ips_nodes.each do |ips, p|
          locations = p['locations'] || {}
          enrichment = {
            'index_partitions' => [1, p['index_partitions'].nil? ? 5 : p['index_partitions'].to_i].max,
            'index_replicas' => [1, p['index_replicas'].nil? ? 1 : p['index_replicas'].to_i].max,
            'sensor_uuid' => p['sensor_uuid'],
            'sensor_name' => Chef::Node.load(ips)['rbname'],
          }
          locations_list.each { |loc| enrichment[loc] = locations[loc] if locations.key?(loc) }
          enrichment_map[p['sensor_uuid']] = enrichment
        end
      end

      (proxy_nodes || {}).each do |_proxy, p|
        locations = p['locations'] || {}
        enrichment = {
          'index_partitions' => [1, p['index_partitions'].nil? ? 5 : p['index_partitions'].to_i].max,
          'index_replicas' => [1, p['index_replicas'].nil? ? 1 : p['index_replicas'].to_i].max,
          'proxy_uuid' => p['sensor_uuid'],
        }
        # a proxy with mapped sensors must not overwrite the sensor_uuid of their events
        mapped = (p['sensors_mapping'] || {}).values.any? { |v| !v.empty? }
        enrichment['sensor_uuid'] = p['sensor_uuid'] unless mapped
        locations_list.each { |loc| enrichment[loc] = locations[loc] if locations.key?(loc) }
        enrichment_map[p['sensor_uuid']] = enrichment
      end

      {
        'brokers' => kafka_hosts.first(5).map { |host| "#{host}.node:9092" },
        'topic' => 'x2kafka_unrouted',
        'client_id' => 'http2k',
        'async' => true,
        'stats_port' => 7982,
        'stats_bind' => '127.0.0.1',
        'stats_socket' => '/run/http2k/http2k.sock',
        'listeners' => [
          {
            'name' => 'http2k',
            'proto' => 'http',
            'bind' => '0.0.0.0',
            'port' => port,
            'mode' => 'json',
            # bodies are whole kafka2x batches, x2kafka defaults to 64KB
            'max_msg_size' => 16 * 1024 * 1024,
            'enrichment_key' => 'sensor_uuid',
            'enrichment_map' => enrichment_map,
          },
        ],
      }
    end
  end
end
