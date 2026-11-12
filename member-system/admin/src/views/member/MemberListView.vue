<template>
  <div class="page-container">
    <!-- 筛选区 -->
    <el-card class="filter-card" shadow="never">
      <el-form inline @submit.prevent>
        <el-form-item label="关键词">
          <el-input
            v-model="query.keyword"
            placeholder="姓名 / 手机号 / 会员编号"
            clearable
            style="width: 220px"
            @keyup.enter="onSearch"
            @clear="onSearch"
          />
        </el-form-item>
        <el-form-item label="等级">
          <el-select v-model="query.levelId" placeholder="全部等级" clearable style="width: 130px" @change="onSearch">
            <el-option v-for="l in levels" :key="l.id" :label="l.name" :value="l.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="标签">
          <el-select v-model="query.tagId" placeholder="全部标签" clearable style="width: 130px" @change="onSearch">
            <el-option v-for="t in tags" :key="t.id" :label="t.name" :value="t.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="query.status" placeholder="全部" clearable style="width: 100px" @change="onSearch">
            <el-option label="正常" :value="1" />
            <el-option label="禁用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="注册时间">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 240px"
            @change="onSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="onSearch">查询</el-button>
          <el-button :icon="Refresh" @click="onReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 列表 -->
    <el-card class="table-card" shadow="never">
      <div class="toolbar">
        <div>
          <el-button type="primary" :icon="Plus" @click="openForm()">新增会员</el-button>
          <el-button :icon="Upload" @click="importVisible = true">Excel 导入</el-button>
          <el-button :icon="Download" @click="onExport">导出 Excel</el-button>
          <el-button :disabled="!selection.length" :icon="CollectionTag" @click="openBatchTag">
            批量打标签{{ selection.length ? `(${selection.length})` : '' }}
          </el-button>
        </div>
        <span class="text-muted">共 {{ total }} 位会员</span>
      </div>

      <el-table v-loading="loading" :data="list" stripe @selection-change="selection = $event">
        <el-table-column type="selection" width="44" />
        <el-table-column prop="memberNo" label="会员编号" width="150" />
        <el-table-column label="会员" min-width="110">
          <template #default="{ row }">
            <el-link type="primary" @click="openDetail(row)">{{ row.name }}</el-link>
            <div class="text-muted">{{ row.phone }}</div>
          </template>
        </el-table-column>
        <el-table-column label="性别" width="60">
          <template #default="{ row }">{{ ['未知', '男', '女'][row.gender] }}</template>
        </el-table-column>
        <el-table-column label="等级" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.level" size="small" :color="row.level.color" effect="dark" style="border: none">
              {{ row.level.name }}
            </el-tag>
            <span v-else class="text-muted">未分级</span>
          </template>
        </el-table-column>
        <el-table-column label="标签" min-width="150">
          <template #default="{ row }">
            <el-tag v-for="t in row.tags" :key="t.id" size="small" class="tag-item" :color="t.color" effect="plain">
              {{ t.name }}
            </el-tag>
            <span v-if="!row.tags?.length" class="text-muted">—</span>
          </template>
        </el-table-column>
        <el-table-column prop="points" label="积分" width="80" align="right" sortable />
        <el-table-column label="储值余额" width="100" align="right">
          <template #default="{ row }">¥{{ row.balance }}</template>
        </el-table-column>
        <el-table-column label="累计消费" width="110" align="right" sortable prop="totalConsumption">
          <template #default="{ row }">¥{{ row.totalConsumption }}</template>
        </el-table-column>
        <el-table-column label="最近消费" width="110">
          <template #default="{ row }">{{ formatDate(row.lastConsumeAt) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openForm(row)">编辑</el-button>
            <el-button link type="primary" @click="openDetail(row)">详情</el-button>
            <el-popconfirm title="确定删除该会员吗？（软删除，可恢复数据）" @confirm="onDelete(row)">
              <template #reference>
                <el-button link type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="query.page"
          v-model:page-size="query.size"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          background
          @change="loadList"
        />
      </div>
    </el-card>

    <!-- 新增 / 编辑 -->
    <el-dialog v-model="formVisible" :title="form.id ? '编辑会员' : '新增会员'" width="560px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="90px">
        <el-row :gutter="12">
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="form.name" placeholder="会员姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="form.phone" placeholder="11 位手机号" maxlength="11" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别">
              <el-radio-group v-model="form.gender">
                <el-radio :value="1">男</el-radio>
                <el-radio :value="2">女</el-radio>
                <el-radio :value="0">未知</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="生日">
              <el-date-picker v-model="form.birthday" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="会员等级">
              <el-select v-model="form.levelId" placeholder="选择等级" clearable style="width: 100%">
                <el-option v-for="l in levels" :key="l.id" :label="l.name" :value="l.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" v-if="form.id">
              <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="正常" inactive-text="禁用" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="会员标签">
              <el-select v-model="form.tagIds" multiple placeholder="选择标签" style="width: 100%">
                <el-option v-for="t in tags" :key="t.id" :label="t.name" :value="t.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="来源">
              <el-input v-model="form.source" placeholder="如：门店注册 / 小程序" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属门店">
              <el-input v-model="form.storeName" placeholder="门店名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="!form.id">
            <el-form-item label="初始积分">
              <el-input-number v-model="form.points" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="!form.id">
            <el-form-item label="初始储值">
              <el-input-number v-model="form.balance" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注">
              <el-input v-model="form.remark" type="textarea" :rows="2" maxlength="255" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- 导入 -->
    <el-dialog v-model="importVisible" title="Excel 批量导入会员" width="480px" destroy-on-close>
      <el-alert type="info" :closable="false" style="margin-bottom: 12px">
        请使用标准模板填写，手机号必填且作为唯一标识；重复手机号可跳过或覆盖更新。
      </el-alert>
      <el-button link type="primary" :icon="Download" @click="onDownloadTemplate">下载导入模板</el-button>
      <el-form label-width="90px" style="margin-top: 12px">
        <el-form-item label="重复数据">
          <el-radio-group v-model="importMode">
            <el-radio value="skip">跳过（保留已有）</el-radio>
            <el-radio value="update">覆盖更新</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="选择文件">
          <el-upload
            ref="uploadRef"
            :auto-upload="false"
            :limit="1"
            accept=".xlsx,.xls"
            :on-change="(f: any) => (importFile = f.raw)"
          >
            <el-button :icon="FolderOpened">选择 xlsx 文件</el-button>
          </el-upload>
        </el-form-item>
      </el-form>
      <el-result
        v-if="importResult"
        :icon="importResult.failed.length ? 'warning' : 'success'"
        title="导入完成"
        :sub-title="`共 ${importResult.total} 行：新增 ${importResult.created}，更新 ${importResult.updated}，跳过 ${importResult.skipped}，失败 ${importResult.failed.length}`"
      />
      <el-alert v-if="importResult?.failed.length" type="error" :closable="false" style="margin-bottom: 12px">
        <div v-for="(f, i) in importResult.failed.slice(0, 5)" :key="i">
          第 {{ f.row }} 行：{{ f.reason || f.message || f }}
        </div>
        <div v-if="importResult.failed.length > 5">… 其余 {{ importResult.failed.length - 5 }} 条略</div>
      </el-alert>
      <template #footer>
        <el-button @click="importVisible = false">关闭</el-button>
        <el-button type="primary" :loading="importing" :disabled="!importFile" @click="onImport">开始导入</el-button>
      </template>
    </el-dialog>

    <!-- 批量打标签 -->
    <el-dialog v-model="batchTagVisible" title="批量打标签" width="440px" destroy-on-close>
      <p class="text-muted" style="margin-top: 0">已对 {{ selection.length }} 位会员执行操作</p>
      <el-form label-width="80px">
        <el-form-item label="操作方式">
          <el-radio-group v-model="batchTagForm.mode">
            <el-radio value="add">追加标签</el-radio>
            <el-radio value="set">覆盖标签</el-radio>
            <el-radio value="remove">移除标签</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="标签">
          <el-select v-model="batchTagForm.tagIds" multiple style="width: 100%" placeholder="选择标签">
            <el-option v-for="t in tags" :key="t.id" :label="t.name" :value="t.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="batchTagVisible = false">取消</el-button>
        <el-button type="primary" @click="onBatchTag">确定</el-button>
      </template>
    </el-dialog>

    <!-- 详情抽屉 -->
    <el-drawer v-model="detailVisible" size="620px" :title="detail?.name ? `会员详情 · ${detail.name}` : '会员详情'">
      <template v-if="detail">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="会员编号">{{ detail.memberNo }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ detail.phone }}</el-descriptions-item>
          <el-descriptions-item label="等级">{{ detail.level?.name || '未分级' }}</el-descriptions-item>
          <el-descriptions-item label="生日">{{ detail.birthday || '—' }}</el-descriptions-item>
          <el-descriptions-item label="积分">{{ detail.points }}</el-descriptions-item>
          <el-descriptions-item label="储值余额">¥{{ detail.balance }}</el-descriptions-item>
          <el-descriptions-item label="累计消费">¥{{ detail.totalConsumption }}</el-descriptions-item>
          <el-descriptions-item label="消费次数">{{ detail.consumptionCount }}</el-descriptions-item>
          <el-descriptions-item label="来源">{{ detail.source || '—' }}</el-descriptions-item>
          <el-descriptions-item label="门店">{{ detail.storeName || '—' }}</el-descriptions-item>
          <el-descriptions-item label="注册时间">{{ formatDateTime(detail.createdAt) }}</el-descriptions-item>
          <el-descriptions-item label="最近消费">{{ formatDateTime(detail.lastConsumeAt) }}</el-descriptions-item>
          <el-descriptions-item label="标签" :span="2">
            <el-tag v-for="t in detail.tags" :key="t.id" size="small" class="tag-item">{{ t.name }}</el-tag>
            <span v-if="!detail.tags?.length">—</span>
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ detail.remark || '—' }}</el-descriptions-item>
        </el-descriptions>

        <div style="margin: 14px 0">
          <el-button size="small" type="primary" plain @click="pointsVisible = true">调整积分</el-button>
          <el-button size="small" type="success" plain @click="rechargeVisible = true">储值充值</el-button>
        </div>

        <el-tabs v-model="detailTab">
          <el-tab-pane label="最近订单" name="orders">
            <el-table :data="memberOrders" size="small">
              <el-table-column prop="orderNo" label="订单号" min-width="160" />
              <el-table-column label="实付" width="90" align="right">
                <template #default="{ row }">¥{{ row.payAmount }}</template>
              </el-table-column>
              <el-table-column label="时间" min-width="120">
                <template #default="{ row }">{{ formatDateTime(row.consumeAt) }}</template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
          <el-tab-pane label="持有优惠券" name="coupons">
            <el-table :data="memberCoupons" size="small">
              <el-table-column label="券名" min-width="130">
                <template #default="{ row }">{{ row.template?.name }}</template>
              </el-table-column>
              <el-table-column label="状态" width="80">
                <template #default="{ row }">
                  <el-tag size="small" :type="['success', 'info', 'danger'][row.status]">
                    {{ ['未使用', '已使用', '已过期'][row.status] }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="过期时间" min-width="110">
                <template #default="{ row }">{{ formatDate(row.expireAt) }}</template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
        </el-tabs>
      </template>
    </el-drawer>

    <!-- 调整积分 -->
    <el-dialog v-model="pointsVisible" title="调整积分" width="400px" destroy-on-close>
      <el-form label-width="80px">
        <el-form-item label="积分变动">
          <el-input-number v-model="pointsForm.points" :step="10" style="width: 100%" />
          <div class="text-muted">正数增加、负数扣减，如 100 或 -50</div>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="pointsForm.remark" placeholder="调整原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pointsVisible = false">取消</el-button>
        <el-button type="primary" @click="onAdjustPoints">确定</el-button>
      </template>
    </el-dialog>

    <!-- 储值充值 -->
    <el-dialog v-model="rechargeVisible" title="储值充值" width="400px" destroy-on-close>
      <el-form label-width="80px">
        <el-form-item label="充值金额">
          <el-input-number v-model="rechargeForm.amount" :min="0.01" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="rechargeForm.remark" placeholder="充值备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rechargeVisible = false">取消</el-button>
        <el-button type="primary" @click="onRecharge">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue';
import dayjs from 'dayjs';
import { ElMessage, type FormInstance, type FormRules } from 'element-plus';
import {
  CollectionTag,
  Download,
  FolderOpened,
  Plus,
  Refresh,
  Search,
  Upload,
} from '@element-plus/icons-vue';
import {
  adjustPoints,
  batchTag,
  createMember,
  deleteMember,
  getLevels,
  getMember,
  getMemberCoupons,
  getMembers,
  getOrders,
  getTags,
  importMembers,
  rechargeMember,
  updateMember,
} from '../../api';
import { downloadFile } from '../../api/request';

const formatDate = (v?: string) => (v ? dayjs(v).format('YYYY-MM-DD') : '—');
const formatDateTime = (v?: string) => (v ? dayjs(v).format('YYYY-MM-DD HH:mm') : '—');

const loading = ref(false);
const list = ref<any[]>([]);
const total = ref(0);
const levels = ref<any[]>([]);
const tags = ref<any[]>([]);
const selection = ref<any[]>([]);
const dateRange = ref<[string, string] | null>(null);

const query = reactive({
  page: 1,
  size: 20,
  keyword: '',
  levelId: undefined as number | undefined,
  tagId: undefined as number | undefined,
  status: undefined as number | undefined,
});

function buildParams() {
  const raw: Record<string, unknown> = {
    ...query,
    startDate: dateRange.value?.[0],
    endDate: dateRange.value?.[1],
  };
  // 清空的筛选项（'' / undefined / null）不下发，避免后端校验 400
  return Object.fromEntries(Object.entries(raw).filter(([, v]) => v !== '' && v !== undefined && v !== null));
}

async function loadList() {
  loading.value = true;
  try {
    const res: any = await getMembers(buildParams());
    list.value = res.list;
    total.value = res.total;
  } finally {
    loading.value = false;
  }
}

function onSearch() {
  query.page = 1;
  loadList();
}

function onReset() {
  query.keyword = '';
  query.levelId = undefined;
  query.tagId = undefined;
  query.status = undefined;
  dateRange.value = null;
  onSearch();
}

// ---------- 新增 / 编辑 ----------
const formVisible = ref(false);
const saving = ref(false);
const formRef = ref<FormInstance>();
const emptyForm = {
  id: 0,
  name: '',
  phone: '',
  gender: 0,
  birthday: '',
  levelId: undefined as number | undefined,
  tagIds: [] as number[],
  source: '',
  storeName: '',
  points: 0,
  balance: 0,
  status: 1,
  remark: '',
};
const form = reactive({ ...emptyForm });
const formRules: FormRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' },
  ],
};

function openForm(row?: any) {
  Object.assign(form, emptyForm, row ? {
    id: row.id,
    name: row.name,
    phone: row.phone,
    gender: row.gender,
    birthday: row.birthday,
    levelId: row.levelId,
    tagIds: row.tags?.map((t: any) => t.id) ?? [],
    source: row.source,
    storeName: row.storeName,
    status: row.status,
    remark: row.remark,
  } : {});
  formVisible.value = true;
}

async function onSave() {
  await formRef.value?.validate();
  saving.value = true;
  try {
    if (form.id) {
      await updateMember(form.id, { ...form });
      ElMessage.success('会员已更新');
    } else {
      await createMember({ ...form });
      ElMessage.success('会员已创建');
    }
    formVisible.value = false;
    loadList();
  } finally {
    saving.value = false;
  }
}

async function onDelete(row: any) {
  await deleteMember(row.id);
  ElMessage.success('已删除');
  loadList();
}

// ---------- 导入导出 ----------
const importVisible = ref(false);
const importing = ref(false);
const importFile = ref<File | null>(null);
const importMode = ref<'skip' | 'update'>('skip');
const importResult = ref<{
  total: number;
  created: number;
  updated: number;
  skipped: number;
  failed: { row: number; reason?: string; message?: string }[];
} | null>(null);

async function onImport() {
  if (!importFile.value) return;
  importing.value = true;
  importResult.value = null;
  try {
    const res: any = await importMembers(importFile.value, importMode.value);
    importResult.value = res;
    ElMessage.success('导入完成');
    loadList();
  } finally {
    importing.value = false;
  }
}

function onDownloadTemplate() {
  downloadFile('/members/import-template', '会员导入模板.xlsx');
}

function onExport() {
  const params = buildParams() as Record<string, unknown>;
  delete params.page;
  delete params.size;
  downloadFile('/members/export', `会员列表_${dayjs().format('YYYY-MM-DD')}.xlsx`, params);
}

// ---------- 批量打标签 ----------
const batchTagVisible = ref(false);
const batchTagForm = reactive({ tagIds: [] as number[], mode: 'add' as 'set' | 'add' | 'remove' });

function openBatchTag() {
  batchTagForm.tagIds = [];
  batchTagForm.mode = 'add';
  batchTagVisible.value = true;
}

async function onBatchTag() {
  if (!batchTagForm.tagIds.length) {
    ElMessage.warning('请选择标签');
    return;
  }
  await batchTag({ memberIds: selection.value.map((m) => m.id), ...batchTagForm });
  ElMessage.success('标签操作完成');
  batchTagVisible.value = false;
  loadList();
}

// ---------- 详情 ----------
const detailVisible = ref(false);
const detail = ref<any>(null);
const detailTab = ref('orders');
const memberOrders = ref<any[]>([]);
const memberCoupons = ref<any[]>([]);

async function openDetail(row: any) {
  detailVisible.value = true;
  detailTab.value = 'orders';
  detail.value = await getMember(row.id);
  memberOrders.value = ((await getOrders({ memberId: row.id, page: 1, size: 10 })) as any).list;
  memberCoupons.value = ((await getMemberCoupons({ memberId: row.id, page: 1, size: 50 })) as any).list;
}

// ---------- 积分 / 充值 ----------
const pointsVisible = ref(false);
const pointsForm = reactive({ points: 0, remark: '' });
const rechargeVisible = ref(false);
const rechargeForm = reactive({ amount: 100, remark: '' });

async function onAdjustPoints() {
  if (!pointsForm.points) {
    ElMessage.warning('请输入非 0 的积分变动值');
    return;
  }
  await adjustPoints(detail.value.id, { ...pointsForm });
  ElMessage.success('积分已调整');
  pointsVisible.value = false;
  detail.value = await getMember(detail.value.id);
  loadList();
}

async function onRecharge() {
  await rechargeMember(detail.value.id, { ...rechargeForm });
  ElMessage.success('充值成功');
  rechargeVisible.value = false;
  detail.value = await getMember(detail.value.id);
  loadList();
}

onMounted(async () => {
  loadList();
  levels.value = (await getLevels()) as any;
  tags.value = (await getTags()) as any;
});
</script>

<style scoped>
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.tag-item {
  margin: 2px 4px 2px 0;
}
</style>
