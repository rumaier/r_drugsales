Language = Language or {}
Language['zh'] = { -- Chinese

    -- Targets
    offer_drugs = '提供毒品',
    robbery_target = '取回被盗毒品',
    make_exchange = '进行交易',

    -- Notifications
    notify_title = '毒品销售',
    police_cant_sell = '警察不能出售毒品。',
    not_enough_police = '在线警察数量不足，无法出售毒品。',
    cant_in_vehicle = '你不能在车辆内出售毒品。',
    not_in_zone = '你不能在此出售毒品。',
    not_enough_drugs = '你没有足够的毒品出售。',
    already_selling = '你已经在出售毒品。',
    abandoned_sale = '你放弃了销售。',
    wait_for_customers = '等待顾客接近你...',
    no_customers_found = '该区域没有顾客，去别的地方吧。',
    sale_finished = '你以$%s出售了%sx %s。',
    sale_denied = '你的报价被拒绝了。',
    sale_robbed = '你被抢劫了，抓住他们！',
    robber_escaped = '劫匪逃跑了，你失去了毒品。',
    robber_caught = '你取回了你的毒品。',
    on_cooldown = '你必须等待%s分钟才能寻找下一个批量订单。',
    head_to_meetup = '前往会面地点。',
    meetup_missed = '你错过了会面，买家已经离开。',
    took_too_long = '你花费的时间太长，客户已经离开。',

    -- UI Elements
    sell_here = '在此出售',
    bulk_order = '寻找批量订单',
    select_drug = '选择毒品',
    selected = '已选择',
    amount = '数量',
    price = '价格',
    cancel = '取消',
    confirm = '确认',
    accept = '接受',
    offer = '报价',

    dialing = '拨号中',
    bulk_request = '客户正在寻找%sx %s，价格$%s，是否接受？',
    meetup_location = '会面地点',

    command_help = '打开毒品交易菜单',

    -- Webhook
    player_id = '玩家ID',
    username = '用户名',
    identifier = '标识符',

    -- Console
    resource_version = '%s | v%s',
    bridge_detected = '^2已检测到并加载Bridge。^0',
    bridge_not_detected = '^1未检测到Bridge，请确保其正在运行。^0',
    cheater_print = '你试图欺骗系统。系统比你更聪明。',
    debug_enabled = '^1调试模式已开启！请勿在生产环境中运行！^0',
}