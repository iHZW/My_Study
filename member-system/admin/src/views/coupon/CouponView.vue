<template>
  <div class="page-container">
    <el-card shadow="never">
      <el-tabs v-model="tab">
        <!-- 券模板 -->
        <el-tab-pane label="券模板管理" name="templates">
          <div class="toolbar">
            <el-button type="primary" :icon="Plus" @click="openForm()">新建券模板</el-button>
          </div>
          <el-table v-loading="loading" :data="templates" stripe>
            <el-table-column prop="name" label="券名" min-width="150" />
            <el-table-column label="类型" width="90">
              <template #default="{ row }">
                <el-tag size="small">{{ typeName(row.type) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="优惠内容" min-width="130">
              <template #default="{ row }">{{ valueText(row) }}</template>
            </el-table-column>
            <el-table-column label="使用门槛" width="110">
              <template #default="{ row }">{{ row.threshold > 0 ? `满 ${row.threshold} 元` : '无门槛' }}</template>
            </el-table-column>
            <el-table-column label="总量" width="90" align="right">
              <template #default="{ row }">{{ row.totalQuantity < 0 ? '不限量' : row.totalQuantity }}</template>
            </el-table-column>
            <el-table-column prop="issuedQuantity" label="已发放" width="80" align="right" />
            <el-table-column prop="usedQuantity" label="已核销" width="80" align="right" />
            <el-table-column label="有效期" width="110">
              <template #default="{ row }">领取后 {{ row.validDays }} 天</template>
            </el-table-column>
            <el-table-column label="状态" width="80">
              <template #default="{ row }">
                <el-tag size="small" :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '启用' : '停用' }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" @click="openIssue(row)">发券</el-button>
                <el-button link type="primary" @click="openForm(row)">编辑</el-button>
                <el-button link :type="row.status === 1 ? 'warning' : 'success'" @click="toggleStatus(row)">
                  {{ row.status === 1 ? '停用' : '启用' }}
                </el-button>
                <el-popconfirm title="确定删除该券模板吗？" @confirm="onDelete(row)">
                  <template #reference>
                    <el-button link type="danger">删除</el-button>
                  </template>
                </el-popconfirm>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <!-- 会员持券 -->
        <el-tab-pane label="会员持券查询" name="memberCoupons">
          <el-form inline>
            <el-form-item label="券模板">
              <el-select v-model="mcQuery.templateId" clearable placeholder="全部" style="width: 180px" @change="loadMemberCoupons">
                <el-option v-for="t in templates" :key="t.id" :label="t.name" :value="t.id" />
              </el-select>
            </el-form-item>
            <el-form-item label="状态">
              <el-select v-model="mcQuery.status" clearable placeholder="全部" style="width: 120px" @change="loadMemberCoupons">
                <el-option label="未使用" :value="0" />
                <el-option label="已使用" :value="1" />
                <el-option label="已过期" :value="2" />
              </el-select>
            </el-form-item>
          </el-form>
          <el-table v-loading="mcLoading" :data="memberCoupons" stripe>
            <el-table-column prop="code" label="券码" min-width="160" />
            <el-table-column label="券名" min-width="130">
              <template #default="{ row }">{{ row.template?.name }}</template>
            </el-table-column>
            <el-table-column label="持有会员" min-width="110">
              <template #default="{ row }">
                <div>{{ row.member?.name }}</div>
                <div class="text-muted">{{ row.member?.phone }}</div>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="90">
              <template #default="{ row }">
                <el-tag size="small" :type="(['success', 'info', 'danger'] as const)[row.status]">
                  {{ ['未使用', '已使用', '已过期'][row.status] }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="领取时间" width="150">
              <template #default="{ row }">{{ formatTime(row.receiveAt) }}</template>
            </el-table-column>
            <el-table-column label="过期时间" width="150">
              <template #default="{ row }">{{ formatTime(row.expireAt) }}</template>
            </el-table-column>
            <el-table-column label="核销订单" min-width="150">
              <template #default="{ row }">{{ row.usedOrderNo || '—' }}</template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrap">
            <el-pagination
              v-model:current-page="mcQuery.page"
              v-model:page-size="mcQuery.size"
              :total="mcTotal"
              layout="total, prev, pager, next"
              background
              @change="loadMemberCoupons"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 模板编辑 -->
    <el-dialog v-model="formVisible" :title="form.id ? '编辑券模板' : '新建券模板'" width="500px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="券名" prop="name">
          <el-input v-model="form.name" placeholder="如：新客满 50 减 10" />
        </el-form-item>
        <el-form-item label="券类型" prop="type">
          <el-radio-group v-model="form.type">
            <el-radio :value="1">满减券</el-radio>
            <el-radio :value="2">折扣券</el-radio>
            <el-radio :value="3">代金券</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="使用门槛">
          <el-input-number v-model="form.threshold" :min="0" :precision="2" style="width: 100%" />
          <div class="text-muted">订单金额满多少元可用，0 为无门槛</div>
        </el-form-item>
        <el-form-item :label="form.type === 2 ? '折扣率' : '优惠金额'" prop="value">
          <el-input-number
            v-model="form.value"
            :min="0.01"
            :max="form.type === 2 ? 0.99 : undefined"
            :precision="2"
            :step="form.type === 2 ? 0.05 : 1"
            style="width: 100%"
          />
          <div class="text-muted">{{ form.type === 2 ? '0.88 表示 88 折' : '直接抵扣的金额（元）' }}</div>
        </el-form-item>
        <el-form-item label="发放总量">
          <el-input-number v-model="form.totalQuantity" :min="-1" style="width: 100%" />
          <div class="text-muted">-1 表示不限量</div>
        </el-form-item>
        <el-form-item label="有效天数">
          <el-input-number v-model="form.validDays" :min="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="onSave">保存</el-button>
      </template>
    </el-dialog>

    <!-- 发券 -->
    <el-dialog v-model="issueVisible" title="给会员发券" width="500px" destroy-on-close>
      <el-form label-width="90px">
        <el-form-item label="券模板">
          <el-input :model-value="issueTemplate?.name" disabled />
          <div class="text-muted">领取后 {{ issueTemplate?.validDays }} 天内有效</div>
        </el-form-item>
        <el-form-item label="目标会员" required>
          <el-select
            v-model="issueMemberIds"
            multiple
            filterable
            remote
            :remote-method="searchMembers"
            placeholder="搜索并选择会员（可多选）"
            style="width: 100%"
          >
            <el-option v-for="m in memberOptions" :key="m.id" :value="m.id" :label="`${m.name}（${m.phone}）`" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="issueVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!issueMemberIds.length" @click="onIssue">发放</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue';
import dayjs from 'dayjs';
import { ElMessage, type FormInstance, type FormRules } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import {
  createCouponTemplate,
  deleteCouponTemplate,
  getCouponTemplates,
  getMemberCoupons,
  getMembers,
  issueCoupon,
  updateCouponTemplate,
} from '../../api';

const formatTime = (v?: string) => (v ? dayjs(v).format('YYYY-MM-DD HH:mm') : '—');
const typeName = (t: number) => ({ 1: '满减券', 2: '折扣券', 3: '代金券' } as Record<number, string>)[t];
const valueText = (row: any) =>
  row.type === 2 ? `${(row.value * 10).toFixed(1)} 折` : `减 ¥${row.value}`;

const tab = ref('templates');
const loading = ref(false);
const templates = ref<any[]>([]);

async function loadTemplates() {
  loading.value = true;
  try {
    templates.value = (await getCouponTemplates()) as any;
  } finally {
    loading.value = false;
  }
}

// ---------- 模板编辑 ----------
const formVisible = ref(false);
const formRef = ref<FormInstance>();
const emptyForm = { id: 0, name: '', type: 1, threshold: 0, value: 10, totalQuantity: -1, validDays: 30, remark: '' };
const form = reactive({ ...emptyForm });
const rules: FormRules = {
  name: [{ required: true, message: '请输入券名', trigger: 'blur' }],
  value: [{ required: true, message: '请输入优惠值', trigger: 'blur' }],
};

function openForm(row?: any) {
  Object.assign(form, emptyForm, row ? {
    id: row.id, name: row.name, type: row.type, threshold: Number(row.threshold),
    value: Number(row.value), totalQuantity: row.totalQuantity, validDays: row.validDays, remark: row.remark,
  } : {});
  formVisible.value = true;
}

async function onSave() {
  await formRef.value?.validate();
  if (form.id) {
    await updateCouponTemplate(form.id, { ...form });
  } else {
    await createCouponTemplate({ ...form });
  }
  ElMessage.success('已保存');
  formVisible.value = false;
  loadTemplates();
}

async function toggleStatus(row: any) {
  await updateCouponTemplate(row.id, { status: row.status === 1 ? 0 : 1 });
  ElMessage.success(row.status === 1 ? '已停用' : '已启用');
  loadTemplates();
}

async function onDelete(row: any) {
  await deleteCouponTemplate(row.id);
  ElMessage.success('已删除');
  loadTemplates();
}

// ---------- 发券 ----------
const issueVisible = ref(false);
const issueTemplate = ref<any>(null);
const issueMemberIds = ref<number[]>([]);
const memberOptions = ref<any[]>([]);

function openIssue(row: any) {
  issueTemplate.value = row;
  issueMemberIds.value = [];
  issueVisible.value = true;
  searchMembers('');
}

async function searchMembers(kw: string) {
  const res: any = await getMembers({ keyword: kw, page: 1, size: 20 });
  memberOptions.value = res.list;
}

async function onIssue() {
  const res: any = await issueCoupon({ templateId: issueTemplate.value.id, memberIds: issueMemberIds.value });
  ElMessage.success(`已成功发放 ${res.issued} 张券`);
  issueVisible.value = false;
  loadTemplates();
}

// ---------- 会员持券 ----------
const mcLoading = ref(false);
const memberCoupons = ref<any[]>([]);
const mcTotal = ref(0);
const mcQuery = reactive({ page: 1, size: 20, templateId: undefined as number | undefined, status: undefined as number | undefined });

async function loadMemberCoupons() {
  mcLoading.value = true;
  try {
    const res: any = await getMemberCoupons(mcQuery);
    memberCoupons.value = res.list;
    mcTotal.value = res.total;
  } finally {
    mcLoading.value = false;
  }
}

onMounted(() => {
  loadTemplates();
  loadMemberCoupons();
});
</script>

<style scoped>
.toolbar {
  margin-bottom: 12px;
}
</style>
