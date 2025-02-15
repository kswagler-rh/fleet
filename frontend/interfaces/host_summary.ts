export interface IHostSummaryPlatforms {
  platform: string;
  hosts_count: number;
}

export interface IHostSummaryLabel {
  id: number;
  name: string;
  description: string;
  label_type: string;
}

export interface IHostSummary {
  all_linux_count: number;
  totals_hosts_count: number;
  platforms: IHostSummaryPlatforms[] | null;
  online_count: number;
  offline_count: number;
  mia_count: number; // DEPRECATED: to be removed in Fleet 5.0
  new_count: number;
  builtin_labels: IHostSummaryLabel[];
}
