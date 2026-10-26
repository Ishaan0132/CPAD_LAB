
import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  ScrollView,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import * as Network from 'expo-network';
import { SafeAreaView } from 'react-native-safe-area-context';

// Infer the network state type directly from Expo Network.
type NetworkState = Awaited<
  ReturnType<typeof Network.getNetworkStateAsync>
>;

export default function ConnectivityScreen() {
  const [network, setNetwork] = useState<NetworkState>({
    type: Network.NetworkStateType.UNKNOWN,
    isConnected: null,
    isInternetReachable: null,
  });

  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [lastChecked, setLastChecked] = useState<Date | null>(null);
  const [error, setError] = useState('');

  // Store a newly received network state.
  const updateNetwork = useCallback((state: NetworkState) => {
    setNetwork(state);
    setLastChecked(new Date());
    setError('');
  }, []);

  // Manually fetch the current network state.
  const refreshNetwork = useCallback(async () => {
    setRefreshing(true);

    try {
      const state = await Network.getNetworkStateAsync();
      updateNetwork(state);
    } catch {
      setError('Unable to refresh network status. Please try again.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [updateNetwork]);

  // Fetch initial state and subscribe to automatic updates.
  useEffect(() => {
    let mounted = true;

    const initialize = async () => {
      try {
        const state = await Network.getNetworkStateAsync();

        if (mounted) {
          updateNetwork(state);
        }
      } catch {
        if (mounted) {
          setError('Unable to retrieve network status.');
        }
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    void initialize();

    const subscription = Network.addNetworkStateListener((state) => {
      if (mounted) {
        updateNetwork(state);
        setLoading(false);
      }
    });

    return () => {
      mounted = false;
      subscription.remove();
    };
  }, [updateNetwork]);

  // Convert the network type into a readable label.
  const getConnectionType = (
    type: NetworkState['type']
  ): string => {
    switch (type) {
      case Network.NetworkStateType.WIFI:
        return 'Wi-Fi';

      case Network.NetworkStateType.CELLULAR:
        return 'Mobile Data';

      case Network.NetworkStateType.ETHERNET:
        return 'Ethernet';

      case Network.NetworkStateType.NONE:
        return 'No Connection';

      case Network.NetworkStateType.UNKNOWN:
        return 'Unknown';

      default:
        return String(type);
    }
  };

  // Determine the display status using both connectivity flags.
  const getStatus = () => {
    if (network.isConnected === false) {
      return {
        label: 'OFFLINE',
        message: 'No network connection',
        color: '#DC2626',
        background: '#FEE2E2',
        icon: '×',
      };
    }

    if (network.isInternetReachable === false) {
      return {
        label: 'NO INTERNET',
        message: 'Connected, but internet is unavailable',
        color: '#D97706',
        background: '#FEF3C7',
        icon: '!',
      };
    }

    if (
      network.isConnected === true &&
      network.isInternetReachable === true
    ) {
      return {
        label: 'ONLINE',
        message: 'Internet connection available',
        color: '#15803D',
        background: '#DCFCE7',
        icon: '✓',
      };
    }

    return {
      label: 'CHECKING',
      message: 'Network status is not yet confirmed',
      color: '#64748B',
      background: '#E2E8F0',
      icon: '?',
    };
  };

  const status = getStatus();

  const formattedTime = lastChecked
    ? lastChecked.toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      })
    : 'Not checked yet';

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" />

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Screen heading */}
        <View style={styles.header}>
          <Text style={styles.appTitle}>
            Connectivity Status
          </Text>

          <Text style={styles.subtitle}>
            Monitor your network connection
          </Text>
        </View>

        {/* Main status card */}
        <View style={styles.card}>
          {loading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color="#2563EB" />

              <Text style={styles.loadingText}>
                Checking connectivity...
              </Text>
            </View>
          ) : (
            <>
              {/* Online/offline indicator */}
              <View
                style={[
                  styles.statusCircle,
                  {
                    backgroundColor: status.background,
                    borderColor: status.color,
                  },
                ]}
              >
                <Text
                  style={[
                    styles.statusIcon,
                    { color: status.color },
                  ]}
                >
                  {status.icon}
                </Text>

                <Text
                  style={[
                    styles.statusLabel,
                    { color: status.color },
                  ]}
                >
                  {status.label}
                </Text>
              </View>

              <Text style={styles.statusMessage}>
                {status.message}
              </Text>

              {/* Connection information */}
              <View style={styles.infoBox}>
                <View style={styles.infoRow}>
                  <Text style={styles.infoIcon}>⌁</Text>

                  <View style={styles.infoTextContainer}>
                    <Text style={styles.infoLabel}>
                      Connection Type
                    </Text>

                    <Text style={styles.infoValue}>
                      {getConnectionType(network.type)}
                    </Text>
                  </View>
                </View>

                <View style={styles.separator} />

                <View style={styles.infoRow}>
                  <Text style={styles.infoIcon}>◎</Text>

                  <View style={styles.infoTextContainer}>
                    <Text style={styles.infoLabel}>
                      Network Connection
                    </Text>

                    <Text style={styles.infoValue}>
                      {network.isConnected === null
                        ? 'Unknown'
                        : network.isConnected
                        ? 'Connected'
                        : 'Disconnected'}
                    </Text>
                  </View>
                </View>

                <View style={styles.separator} />

                <View style={styles.infoRow}>
                  <Text style={styles.infoIcon}>◉</Text>

                  <View style={styles.infoTextContainer}>
                    <Text style={styles.infoLabel}>
                      Internet Reachability
                    </Text>

                    <Text style={styles.infoValue}>
                      {network.isInternetReachable === null
                        ? 'Unknown'
                        : network.isInternetReachable
                        ? 'Available'
                        : 'Unavailable'}
                    </Text>
                  </View>
                </View>
              </View>

              {/* Error message */}
              {error ? (
                <Text style={styles.errorText}>
                  {error}
                </Text>
              ) : null}

              {/* Manual refresh */}
              <TouchableOpacity
                style={[
                  styles.refreshButton,
                  refreshing && styles.refreshButtonDisabled,
                ]}
                onPress={refreshNetwork}
                disabled={refreshing}
                activeOpacity={0.8}
              >
                {refreshing ? (
                  <ActivityIndicator color="#FFFFFF" />
                ) : (
                  <Text style={styles.refreshIcon}>↻</Text>
                )}

                <Text style={styles.refreshButtonText}>
                  {refreshing
                    ? 'Refreshing...'
                    : 'Refresh Status'}
                </Text>
              </TouchableOpacity>

              {/* Last checked time */}
              <Text style={styles.lastChecked}>
                Last checked: {formattedTime}
              </Text>
            </>
          )}
        </View>

        {/* Automatic monitoring indicator */}
        <View style={styles.footer}>
          <View
            style={[
              styles.liveDot,
              {
                backgroundColor: loading
                  ? '#64748B'
                  : '#16A34A',
              },
            ]}
          />

          <Text style={styles.footerText}>
            Automatic network monitoring enabled
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#F1F5F9',
  },

  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: 22,
    paddingVertical: 28,
  },

  header: {
    alignItems: 'center',
    marginBottom: 28,
  },

  appTitle: {
    fontSize: 28,
    fontWeight: '700',
    color: '#0F172A',
    textAlign: 'center',
  },

  subtitle: {
    fontSize: 14,
    color: '#64748B',
    marginTop: 8,
    textAlign: 'center',
  },

  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 24,
    padding: 24,
    alignItems: 'center',
    shadowColor: '#0F172A',
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.08,
    shadowRadius: 12,
    elevation: 5,
  },

  loadingContainer: {
    paddingVertical: 60,
    alignItems: 'center',
  },

  loadingText: {
    marginTop: 16,
    fontSize: 15,
    color: '#64748B',
  },

  statusCircle: {
    width: 150,
    height: 150,
    borderRadius: 75,
    borderWidth: 4,
    alignItems: 'center',
    justifyContent: 'center',
  },

  statusIcon: {
    fontSize: 48,
    fontWeight: '700',
  },

  statusLabel: {
    fontSize: 17,
    fontWeight: '800',
    marginTop: 2,
  },

  statusMessage: {
    marginTop: 18,
    marginBottom: 24,
    fontSize: 15,
    color: '#334155',
    textAlign: 'center',
  },

  infoBox: {
    width: '100%',
    backgroundColor: '#F8FAFC',
    borderRadius: 16,
    paddingHorizontal: 16,
  },

  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
  },

  infoIcon: {
    width: 42,
    fontSize: 28,
    color: '#475569',
    textAlign: 'center',
    marginRight: 10,
  },

  infoTextContainer: {
    flex: 1,
  },

  infoLabel: {
    fontSize: 13,
    color: '#64748B',
    marginBottom: 5,
  },

  infoValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#0F172A',
  },

  separator: {
    height: 1,
    backgroundColor: '#E2E8F0',
  },

  errorText: {
    color: '#DC2626',
    fontSize: 13,
    textAlign: 'center',
    marginTop: 16,
  },

  refreshButton: {
    width: '100%',
    minHeight: 54,
    backgroundColor: '#2563EB',
    borderRadius: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 24,
    gap: 10,
  },

  refreshButtonDisabled: {
    opacity: 0.7,
  },

  refreshIcon: {
    color: '#FFFFFF',
    fontSize: 26,
    fontWeight: '600',
  },

  refreshButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },

  lastChecked: {
    fontSize: 12,
    color: '#64748B',
    marginTop: 16,
  },

  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 24,
    gap: 8,
  },

  liveDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },

  footerText: {
    color: '#64748B',
    fontSize: 12,
  },
});
