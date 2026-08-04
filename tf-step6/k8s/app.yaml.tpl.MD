# ─────────────────────────────────────────────
# Ingress
# ─────────────────────────────────────────────
# IngressClassParams
apiVersion: eks.amazonaws.com/v1
kind: IngressClassParams
metadata:
  name: alb
spec:
  scheme: internet-facing
---

# IngressClass
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: alb
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: eks.amazonaws.com/alb
  parameters:
    apiGroup: eks.amazonaws.com
    kind: IngressClassParams
    name: alb
---

# ─────────────────────────────────────────────
# Namespace
# ─────────────────────────────────────────────
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAMESPACE}
---

# ─────────────────────────────────────────────
# Was POD에 관련된 Deployment, Service, PDB, HPA
# ─────────────────────────────────────────────
# ─────────────────────────────────────────────
# Deployment (Pod 개수,복구,버전에따른 교체등 관리 총괄 -> 정책 구성 )
# 쿠버네티스가 가동되면 시스템 구성, 데이터베이스, 리소스 객체등이 생성 세팅됨
# Control Plane : Kubernetes 관리 시스템
# etcd          : Kubernetes 내에 각각 업무를 수행하는 객체들을 저장하는 데이터베이스
# Deployment    : etcd에 저장되어 있는 Kubernetes API 리소스 객체로 Pod 관리 업무 수행
# ─────────────────────────────────────────────
apiVersion: apps/v1               # Deployment 기능을 제공하는 api 버전 (고정값, 버전차이 추후 존재)
kind: Deployment                  # 파드의 생성, 복구, 개수 유지 담당
metadata:                         # Deployment 기본 정보
  name: was                       # Deployment 이름
  namespace: ${APP_NAMESPACE}     # Deployment 리소스 객체가 생성되는 네임스페이스
spec:                             # Deployment의 실제 설정
  replicas: 2                     # was 파드는 기본 최소 2개를 실행(운영) -> 설정
  selector:                       # pod 선택 조건
    matchLabels:                  # label을 기준으로 파드 선택 -> 파드 web, was
      app: was                    # app=was 라는 형태로 label을 가진 파드를 관리
  template:                       # Deployment가 관리하는 파드의 설계도
    metadata:                     # 기본정보
      labels:                     # 라벨
        app: was                  # app=was, Deployment 파드 생성시 파드 찾는 조건
        tier: backend             # backend 담당이라는 커스텀 라벨
    spec:                         # 실제 실행 정보
      topologySpreadConstraints:  # 파드를 여러 가용 영역에 분산 배치
        - maxSkew: 1              # AZ별 파드 개수 차이는 최대 1개로 제한
          minDomains: 2           # 최소 2개, 가용 영역에 분산
          topologyKey: topology.kubernetes.io/zone   # 분산 기준(가용영역)을 AZ로 지정
          whenUnsatisfiable: DoNotSchedule           # 분산 조건을 만족하지 않으면 배치x
          labelSelector:          # 분산 규칙을 따르는 파드는 -
            matchLabels:          # 라벨이 일치하는 파드만 적용
              app: was            # app=was 로 구성된 파드만 적용
      containers:
        - name: was
          image: ${WAS_IMAGE}
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 8000
          envFrom:
            - secretRef:
                name: rds-secret
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 15
            periodSeconds: 20
            timeoutSeconds: 3
            failureThreshold: 3
---

# Service
apiVersion: v1
kind: Service
metadata:
  name: was-service
  namespace: ${APP_NAMESPACE}
spec:
  selector:
    app: was
  ports:
    - name: http
      port: 8000
      targetPort: http
  type: ClusterIP
---

# PodDisruptionBudget (PDB)
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: was-pdb
  namespace: ${APP_NAMESPACE}
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: was
---

# HorizontalPodAutoscaler (HPA)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: was-hpa
  namespace: ${APP_NAMESPACE}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: was
  minReplicas: 2
  maxReplicas: 6
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
---

# ─────────────────────────────────────────────
# Web POD에 관련된 Deployment, Service, PDB, HPA
# ─────────────────────────────────────────────
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: ${APP_NAMESPACE}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
        tier: frontend
    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          minDomains: 2
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app: web
      containers:
        - name: web
          image: ${WEB_IMAGE}
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 80
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 300m
              memory: 256Mi
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 3
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 10
            periodSeconds: 20
            timeoutSeconds: 3
            failureThreshold: 3
---

# Service
apiVersion: v1
kind: Service
metadata:
  name: web-service
  namespace: ${APP_NAMESPACE}
spec:
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: http
  type: ClusterIP
---

# PodDisruptionBudget
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
  namespace: ${APP_NAMESPACE}
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: web
---

# HorizontalPodAutoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
  namespace: ${APP_NAMESPACE}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 6
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: public-alb
  namespace: ${APP_NAMESPACE}
spec:
  ingressClassName: alb
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
