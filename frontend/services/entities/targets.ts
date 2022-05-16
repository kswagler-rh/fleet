/* eslint-disable  @typescript-eslint/explicit-module-boundary-types */
import sendRequest from "services";
import { IHost } from "interfaces/host";
import { ISelectedTargets, ITargetsAPIResponse } from "interfaces/target";
import endpoints from "utilities/endpoints";
import appendTargetTypeToTargets from "utilities/append_target_type_to_targets";

interface ITargetsProps {
  query?: string;
  queryId?: number | null;
  selected: ISelectedTargets;
}

const defaultSelected = {
  hosts: [],
  labels: [],
  teams: [],
};

export interface ITargetsSearchParams {
  query_id?: number | null;
  query: string;
  selected_host_ids: number[] | null;
}

export interface ITargetsSearchResponse {
  targets: {
    hosts: IHost[];
  };
}

export interface ITargetsCountParams {
  query_id?: number | null;
  selected: ISelectedTargets | null;
}

export interface ITargetsCountResponse {
  targets_count: number;
  targets_online: number;
  targets_offline: number;
}
// TODO: deprecated until frontend\components\forms\fields\SelectTargetsDropdown
// is fully replaced with frontend\components\TargetsInput
const DEPRECATED_defaultSelected = {
  hosts: [],
  labels: [],
};

export default {
  loadAll: ({
    query = "",
    queryId = null,
    selected = defaultSelected,
  }: ITargetsProps): Promise<ITargetsAPIResponse> => {
    const { TARGETS } = endpoints;

    return sendRequest("POST", TARGETS, {
      query,
      query_id: queryId,
      selected,
    });
  },
  search: (params: ITargetsSearchParams): Promise<ITargetsSearchResponse> => {
    if (!params?.selected_host_ids || !params?.query) {
      return Promise.reject("Invalid usage: missing required parameter(s)");
    }
    const { TARGETS } = endpoints;
    const path = `${TARGETS}/search`;

    return sendRequest("POST", path, params);
  },
  count: (params: ITargetsCountParams): Promise<ITargetsCountResponse> => {
    if (!params?.selected) {
      return Promise.reject("Invalid usage: no selected targets");
    }
    const { TARGETS } = endpoints;
    const path = `${TARGETS}/count`;

    return sendRequest("POST", path, params);
  },
  // TODO: deprecated until frontend\components\forms\fields\SelectTargetsDropdown
  // is fully replaced with frontend\components\TargetsInput
  DEPRECATED_loadAll: (
    query = "",
    queryId = null,
    selected = DEPRECATED_defaultSelected
  ) => {
    const { TARGETS } = endpoints;
    return sendRequest("POST", TARGETS, {
      query,
      query_id: queryId,
      selected,
    }).then((response) => {
      const { targets } = response;
      return {
        ...response,
        targets: [
          ...appendTargetTypeToTargets(targets.hosts, "hosts"),
          ...appendTargetTypeToTargets(targets.labels, "labels"),
          ...appendTargetTypeToTargets(targets.teams, "teams"),
        ],
      };
    });
  },
};
